package de.jabc.cinco.meta.core.ui.handlers;

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.eapi;
import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;
import de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.NotEnabledException;
import org.eclipse.core.commands.NotHandledException;
import org.eclipse.core.commands.common.NotDefinedException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceDescription;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.xtext.xbase.lib.Pair;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.mgl.MGLEPackageRegistry;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.ui.templates.NewProjectWizardGenerator;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.GeneratorHelper;
import de.jabc.cinco.meta.core.utils.dependency.DependencyGraph;
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode;
import de.jabc.cinco.meta.core.utils.job.Workload;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.cpdpreprocessor.CPDPreprocessorPlugin;
import mgl.GraphModel;
import mgl.Import;
import mgl.MglPackage;
import productDefinition.CincoProduct;
import productDefinition.MGLDescriptor;
import transem.utility.helper.Tuple;


/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class CincoProductGenerationHandler extends AbstractHandler {
	
	/**
	 * The constructor.
	 */
	public CincoProductGenerationHandler() {}
	
	ICommandService commandService;
	private RuntimeException reason;
	private List<GraphModel> mgls;
	private IFile cpdFile;
	private CincoProduct cpd;
	private ExecutionEvent event;
	private boolean autoBuild;

	/**
	 * the command has been executed, so extract the needed information
	 * from the application context and run the build job.
	 */
	synchronized public Object execute(ExecutionEvent executionEvent) throws ExecutionException {
		long startTime = System.nanoTime();
		System.err.println("Starting at: "+startTime);
		event = executionEvent;
		
		StructuredSelection selection = (StructuredSelection) HandlerUtil.getActiveMenuSelection(event);
		if (!(selection.getFirstElement() instanceof IFile))
			return null;
		
		init(); // retrieve command service and cpd file
		mglTopSort(); // collect and sort mgl files
		
		Workload job = job("Generate Cinco Product")
		  .consume(10, "Initializing...")
			.task("Disabling auto-build...", this::disableAutoBuild)
		    .task("Deleting previously generated resources...", this::deleteGeneratedResources)
		    .task("Resetting registries...", this::resetRegistries);
		
		// FIXME this should be put to a CPDMetaPlugin as soon as the plugin structure has been fixed.
		final List<GraphModel> preProcessedMGLs = preprocessMGLs(mgls);
		
		for (GraphModel mgl : preProcessedMGLs) { // execute the following tasks for each mgl file
			Workload tasks = job.consume(50, String.format("Processing %s", mgl.getName()));
			tasks.task("Initializing...", () -> publishMglFile(mgl))
				.task("Generating Ecore/GenModel...", () -> generateEcoreModel(mgl))
				.task("Generating model code...", () -> generateGenmodelCode(mgl))
				.task("Generating Graphiti editor...", () -> generateGraphitiEditor(mgl))
				.task("Generating API...", () -> generateApi(mgl))
				.task("Generating Cinco SIBs...", () -> generateCincoSIBs(mgl))
				.task("Generating product project...", () -> generateProductProject(mgl))
				.task("Generating feature project...", () -> generateFeatureProject(mgl))
				.task("Generating perspective...", () -> generatePerspective(mgl));
			if (isGratextEnabled()) {
				tasks.task("Generating Gratext model...", () -> generateGratextModel(mgl));
			}
		}
		
		job.task("Generate CPD plugins", () -> generateCPDPlugins(mgls));
		
		job.consume(5, "Global Processing")
			.task("Generating project wizard...", this::generateProjectWizard);
		
		if (isGratextEnabled()) {
			job.consumeConcurrent(mgls.size() * 60, "Building Gratext...")
			    .taskForEach(() -> mgls.stream(), this::buildGratext,
						t -> t.getName());
		}
		
		job.onCanceledShowMessage("Cinco Product generation has been canceled")
		  .onFinished(() -> printDebugOutput(event, startTime))
		  .onFinishedShowMessage("Cinco Product generation completed successfully")
		  .schedule();
		
		return null;
	}
	
	/**
	 * backups all provided MGLs and afterwards applies the preprocessing meta plug-in to the original files (potentially changing them).
	 * The returned map provides the reference to the backups for later restore.
	 * 
	 * @param mgls
	 * @return The MGL backups for later restore; key=backup value=(changed) original.
	 */
	private List<GraphModel> preprocessMGLs(List<GraphModel> mgls) {
		try {
			final Set<GraphModel> graphModels = new LinkedHashSet<>(mgls);
			// TODO use CPDMetaPlugin facility...
//			new CPDPreprocessorPlugin().execute(graphModels, cpd, cpdFile.getProject());

			return mgls;
		}
		catch (RuntimeException e) {
			e.printStackTrace();
			throw e;
		}
		catch (Throwable t) {
			t.printStackTrace();
			throw new RuntimeException(t);
		}

	}
	
	/**
	 * Executes the CPD meta plug ins
	 * @param mgls
	 */
	private void generateCPDPlugins(List<GraphModel> mgls) {
		Set<GraphModel> graphModels = new LinkedHashSet<GraphModel>(mgls); 
		PluginRegistry.
		getInstance().
		getPluginCPDGenerators().
		stream().
		filter(
				n->cpd.
				getAnnotations().
				stream().
				filter(e->e.
						getName().
						equals(n.getAnnotationName())).
						findAny().
						isPresent()
				).
		forEach(n->n.getPlugin().execute(graphModels,cpd,cpdFile.getProject()));
	}

	private void init() {
		commandService = (ICommandService) PlatformUI.getWorkbench().getService(ICommandService.class);
		cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
		cpd = eapi(cpdFile).getResourceContent(CincoProduct.class, 0);
	}

	private void resetRegistries() {
		BundleRegistry.resetRegistry();
		MGLEPackageRegistry.resetRegistry();
		
	}

	private void printDebugOutput(ExecutionEvent event, long startTime) {
		long stopTime = System.nanoTime();
		System.err.println("Stopping at: "+stopTime);
		System.err.println(String.format("Generation took %s of your earth minutes.",(stopTime-startTime)*Math.pow(10,-9)/60));
	}

	private void displayErrorDialog(ExecutionEvent event, Exception e1) {
//		StringWriter sw = new StringWriter();
//		PrintWriter pw = new PrintWriter(sw);
//		e1.printStackTrace(pw);
//		
//		List<Status> children = new ArrayList<>();
//		
//		String pluginId = event.getTrigger().getClass().getCanonicalName();
//		for (String line : sw.toString().split(System.lineSeparator())) {
//			Status status = new Status(IStatus.ERROR, pluginId, line);
//			children.add(status);
//		}
//		
//		MultiStatus mstat = new MultiStatus(pluginId, IStatus.ERROR, children.toArray(new IStatus[children.size()]), e1.getLocalizedMessage(), e1);
//		Display display = Display.getCurrent();
//		if(display==null)
//			display = Display.getDefault();
//		display.asyncExec(() ->{
//		ErrorDialog.openError(HandlerUtil.getActiveShell(event), "Error in Cinco Product Generation", "An error occured during generation: ", mstat);});
		
		e1.printStackTrace();
	}
	
	private void publishMglFile(GraphModel mgl) {
		MGLSelectionListener.INSTANCE.putMGLGraphModel(mgl);
	}

	private void generateEcoreModel(GraphModel mglFile) {
		execute("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
	}
	
	private void generateGenmodelCode(GraphModel mgl) {
		IFile mglFile = eapi(mgl.eResource()).getFile();
		try {
			
			GeneratorHelper.generateGenModelCode(mglFile);
		} catch (IOException e) {
			reason = new RuntimeException(String.format("Generation of %s failed", mglFile.getFullPath().lastSegment()),e);
			throw reason;
		}
	}
	
	private void generateGraphitiEditor(GraphModel mgl) {
		execute("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
	}
	
	private void generateApi(GraphModel mgl) {
		ResourceEAPI fileEAPI = eapi(mgl.eResource());
		IProject apiProject = fileEAPI.getProject();
		if (apiProject.exists()) try {
			GeneratorHelper.generateGenModelCode(apiProject, "C"+fileEAPI.getFile().getName().split("\\.")[0]);
		} catch (IOException e) {
			reason = new RuntimeException(String.format("Generation of %s failed", fileEAPI.getFile().getFullPath().lastSegment()),e);
			throw reason;
		}
	}
	
	private void generateCincoSIBs(GraphModel mgl) {
		execute("de.jabc.cinco.meta.core.jabcproject.commands.generateCincoSIBsCommand");
	}
	
	private void generateProductProject(GraphModel mgl) {
		execute("cpd.handler.ui.generate");
	}
	
	private void generateFeatureProject(GraphModel mgl) {
		execute("de.jabc.cinco.meta.core.generatefeature");
	}
	
	private void generatePerspective(GraphModel mgl) {
		generateDefaultPerspective(mgl);
	}
	
	private void generateGratextModel(GraphModel mgl) {
		if (isGratextEnabled()) {
			execute("de.jabc.cinco.meta.plugin.gratext.generategratext");
		}
	}

	private void buildGratext(GraphModel mgl) {
		if (isGratextEnabled()) {
			execute("de.jabc.cinco.meta.plugin.gratext.buildgratext");
		}
	}
	
	private boolean isGratextEnabled() {
		return cpd.getAnnotations().stream().noneMatch(ann -> "disableGratext".equals(ann.getName()));
	}
	
	private EObject loadModel(IFile cpdFile, String fileExtension, EPackage ePkg) throws IOException, CoreException {
		URI createPlatformResourceURI = URI.createPlatformResourceURI(cpdFile.getFullPath().toPortableString(), true);
		Resource res = Resource.Factory.Registry.INSTANCE.getFactory(createPlatformResourceURI, fileExtension).createResource(createPlatformResourceURI);
		ResourceSet set = ePkg.eResource().getResourceSet();
		res.load(cpdFile.getContents(), null);
		return res.getContents().get(0);
	}

	private void deleteGeneratedResources() {
		IProject project = cpdFile.getProject();
		try {
			ArrayList<String> gmPackages = new ArrayList<>();
			for(MGLDescriptor mgl: cpd.getMgls()){
				if(!mgl.isDontGenerate()){
					String mglPath = mgl.getMglPath();
					IFile mglFile = project.getFile(mglPath);
					try {
						EObject eObj = loadModel(mglFile,"mgl",MglPackage.eINSTANCE);
						
						
							if(eObj instanceof GraphModel)
								gmPackages.add(((GraphModel)eObj).getPackage());
						
					
					} catch (IOException e) {
						
						e.printStackTrace();
					}
				}

			}
			Collection<IResource> toDelete = new ArrayList<>();
			toDelete.add(project.findMember("resources-gen/"));
			if(project.getFolder("src-gen/").exists()){
				for (IResource member : project.getFolder("src-gen/").members()) {
					if (member instanceof IFolder
							&& !member.getName().equals("model")) {

						for(String e: gmPackages){
							if(e.startsWith(member.getName()))
								toDelete.add(((IFolder)member.getParent()).getFolder(toPath(e)));
						}
					}
				}
			}

			for (IResource resource : toDelete) {
				if (resource != null) {
					resource.delete(org.eclipse.core.resources.IResource.FORCE,
							null);
				}
			}

		} catch (CoreException e) {
			e.printStackTrace();
		}

	}
	
	private List<GraphModel> mglTopSort(){
		IProject project = cpdFile.getProject();
		ArrayList<Tuple<String,List<String>>> unsorted = new ArrayList<>();
		HashMap<String,Integer> mglPrios = new HashMap<>();
		List<DependencyNode> dns = new ArrayList<DependencyNode>();
		List<String> stacked = new ArrayList<>();
		for(MGLDescriptor mgl: cpd.getMgls()){
			String mglPath = mgl.getMglPath();
			IFile mglFile = project.getFile(mglPath);
			
			if(!mgl.isDontGenerate()){
				
				try {
					EObject eObj = loadModel(mglFile,"mgl",MglPackage.eINSTANCE);
					if(eObj instanceof GraphModel){
						GraphModel gm = (GraphModel)eObj;
						String projectSymbolicName = ProjectCreator.getProjectSymbolicName(project);
						DependencyNode dn = new DependencyNode(gm.eResource().getURI().toPlatformString(true).replace("/"+projectSymbolicName,""));
						//ArrayList<String> before = new ArrayList<String>();
						for(Import imprt : gm.getImports()){
							if(imprt.getImportURI().endsWith(".mgl")){
								if(!imprt.isStealth())
									dn.getDependsOf().add(imprt.getImportURI().replace("platform:/resource/"+projectSymbolicName,""));
							}
						}
						dns.add(dn);
//						//eObj.eResource().getURI().toPlatformString(true)
//						Tuple<String,List<String>> tuple = new Tuple<>(mglPath,before);
//						unsorted.add(tuple);
//						//eObj.eResource().getURI().toPlatformString(true)
//						mglPrios.put(mglPath,0);
						
					}
				} catch (IOException | CoreException e) {
					
					e.printStackTrace();
				}
			}else{
				stacked.add("/"+mgl.getMglPath());
				MGLEPackageRegistry.INSTANCE.addMGLEPackage(getEPackageForMGL(mglFile,project));
			}
			
		}
		DependencyGraph dg = DependencyGraph.createGraph(dns,stacked);
		mgls = dg.topSort().stream().map(path -> {
			try {
				return (GraphModel)loadModel(cpdFile.getProject().getFile(path),"mgl",MglPackage.eINSTANCE);
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
			
		}).collect(Collectors.toList());
		return mgls;
		//HashMap<String,Integer> mglPrios = new HashMap<>();
//		for(Tuple<String, List<String>> e: unsorted){
//			Integer prio = mglPrios.get(e.getLeft());
//			
//				ArrayList<Integer> prios = new ArrayList<Integer>();
//				for(String ep: e.getRight()){
//					Integer p = mglPrios.get(ep);
//					if(p==null)
//						p = 0;
//					
//					prios.add(p);
//				}
//				if(prios.size()>0)
//					prio=prios.stream().min(Integer::min).get()-1;
//				else
//					prio=0;
//				mglPrios.put(e.getLeft(),prio);
//			
//			
//		}
//		List<String> lst = mglPrios.entrySet().stream().sorted((a,b) -> Integer.compare(a.getValue(),b.getValue())).map(e -> e.getKey()).collect(Collectors.toList());
//		return Lists.reverse(lst);
		
	}

	private EPackage getEPackageForMGL(IFile mglFile, IProject project){
		String ecoreName = mglFile.getName().replace(mglFile.getFileExtension(), "ecore");
		String ecorePath = project.getFile("src-gen/model/"+ecoreName).getProjectRelativePath().makeAbsolute().toString();
		URI uri = URI.createPlatformResourceURI(ProjectCreator.getProjectSymbolicName(project)+"/src-gen/model/"+ecoreName, true);
		Resource res = Resource.Factory.Registry.INSTANCE.getFactory(uri).createResource(uri);
		try {
			res.load(null);
			return (EPackage) res.getContents().get(0);
		} catch (IOException e) {
		
			throw new RuntimeException("Failed to load ecore model: "+ecoreName,e);
		}
	}

	private String toPath(String e) {
		return e.replace('.', '/');
	}
	
	private void generateDefaultPerspective(GraphModel mgl) {
		CincoProduct cp = (CincoProduct) CincoUtils.getCPD(cpdFile);
		
		IProject p = cpdFile.getProject();
		IFile pluginXML = p.getFile("plugin.xml");
		String extensionCommentID = "<!--@CincoGen "+cp.getName().toUpperCase()+"-->";
		
		if (cp.getDefaultPerspective() != null && !cp.getDefaultPerspective().isEmpty())
			return;
		
		CharSequence defaultPerspectiveContent = 
				de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent.generateDefaultPerspective(cp, cpdFile);
		CharSequence defaultXMLPerspectiveContent = 
				de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent.generateXMLPerspective(cp, cpdFile.getProject().getName());
		
		IFile file = p.getFile("src-gen/"+p.getName().replace(".", "/")+"/"+cp.getName()+"Perspective.java");
		CincoUtils.writeContentToFile(file, defaultPerspectiveContent.toString());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), defaultXMLPerspectiveContent.toString(), extensionCommentID, p.getName());
	}
	
	private void execute(String commandId) {
		try {
			commandService.getCommand(commandId).executeWithChecks(event);
		} catch (ExecutionException | NotDefinedException | NotEnabledException | NotHandledException e) {
			GraphModel mgl = MGLSelectionListener.INSTANCE.getCurrentMGLGraphModel();
			reason = (mgl != null)
				? new RuntimeException(String.format("Generation of MGL %s failed", mgl.getName()), e)
				: new RuntimeException(String.format("Generation of CPD %s failed", cpdFile.getName()), e);
			throw reason;
		}
	}
	
	private boolean isAutoBuild() {
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IWorkspaceDescription desc = workspace.getDescription();
		return desc.isAutoBuilding();
	}
	
	private void disableAutoBuild() {
		try {
			setAutoBuild(false);
		} catch (Exception e) {
			if (isAutoBuild()) {
				System.out.println("[Gratext] WARN: Failed to deactivate \"Build Automatically\".");
				e.printStackTrace();
			}
		}
	}
	
	private void setAutoBuild(boolean enable) throws CoreException {
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IWorkspaceDescription desc = workspace.getDescription();
		autoBuild = desc.isAutoBuilding();
		if (autoBuild != enable) {
			desc.setAutoBuilding(enable);
			workspace.setDescription(desc);
		}
	}
	
	private void resetAutoBuild() {
		try {
			setAutoBuild(autoBuild);
		} catch (Exception e) {
			if (!autoBuild != isAutoBuild()) {
				System.err.println("[Gratext] WARN: Failed to reset state for \"Build Automatically\". "
						+ "Should be " + autoBuild);
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * used to restore MGL backups:
	 * copies every key IFile to the according value IFile, deletes the key IFile and also each key IFile's parent folder, if it is empty (e.g. when the last backup is restored)
	 */
	private void restoreMGLBackups(Map<IFile, IFile> mgls) {
		for (Entry<IFile, IFile> entry : mgls.entrySet()) {
			try {
				IFile target = entry.getValue();
				IFile source = entry.getKey();
				target.delete(true, null);
				source.copy(target.getFullPath(), true, null);
				source.delete(true, null);
				if (source.getParent().members().length == 0) {
					source.getParent().delete(true, null);
				}
			} catch (CoreException e) {
				e.printStackTrace();
				throw new RuntimeException(e);
			}
		}
	}
	
	private void generateProjectWizard() {
		System.out.println("Generating Project Wizard");
		CincoProduct cp = (CincoProduct) CincoUtils.getCPD(cpdFile);
		
		IProject p = cpdFile.getProject();
		IFile pluginXML = p.getFile("plugin.xml");
		String wizardExtensionCommentID = "<!--@CincoGen PROJECT_WIZARD_"+cp.getName().toUpperCase()+"_WIZ -->";
		String navigatorExtensionCommentID = "<!--@CincoGen PROJECT_WIZARD_"+cp.getName().toUpperCase()+"_NAV -->";
		
		CharSequence wizardJavaCode = 
				NewProjectWizardGenerator.generateWizardJavaCode(cp, cpdFile.getProject().getName());
		CharSequence newWizardXML = 
				NewProjectWizardGenerator.generateNewWizardXML(cp, cpdFile.getProject().getName(), wizardExtensionCommentID);
		CharSequence navigatorXML = 
				NewProjectWizardGenerator.generateNavigatorXML(cp, cpdFile.getProject().getName(), navigatorExtensionCommentID);
		
		IFile file = p.getFile("src-gen/"+p.getName().replace(".", "/")+"/"+cp.getName()+"ProjectWizard.java");
		CincoUtils.writeContentToFile(file, wizardJavaCode.toString());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), newWizardXML.toString(), wizardExtensionCommentID, p.getName());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), navigatorXML.toString(), navigatorExtensionCommentID, p.getName());
	}
	
	private void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private void buildWorkspace() {
		try {
			ResourcesPlugin.getWorkspace().build(IncrementalProjectBuilder.FULL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	
}
