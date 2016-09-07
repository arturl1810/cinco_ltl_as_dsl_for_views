package de.jabc.cinco.meta.core.ui.handlers;

import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.resp;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import mgl.GraphModel;
import mgl.Import;
import mgl.MglPackage;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
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
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.HandlerUtil;

import transem.utility.helper.Tuple;
import ProductDefinition.CincoProduct;
import ProductDefinition.MGLDescriptor;
import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.mgl.MGLEPackageRegistry;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.GeneratorHelper;
import de.jabc.cinco.meta.core.utils.WorkspaceUtil;
import de.jabc.cinco.meta.core.utils.dependency.DependencyGraph;
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode;
import de.jabc.cinco.meta.core.utils.job.JobFactory;
import de.jabc.cinco.meta.core.utils.job.Workload;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;


/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class CincoProductGenerationHandler extends AbstractHandler {
	
	/**
	 * The constructor.
	 */
	public CincoProductGenerationHandler() {
	}
	ICommandService commandService;
	private RuntimeException reason;
	private List<IFile> mgls;
	private IFile cpdFile;
	private CincoProduct cpd;
	private ExecutionEvent event;
	private boolean autoBuild;

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	synchronized public Object execute(ExecutionEvent executionEvent) throws ExecutionException {
		long startTime = System.nanoTime();
		System.err.println("Starting at: "+startTime);
		event = executionEvent;
		
		StructuredSelection selection = (StructuredSelection) HandlerUtil.getActiveMenuSelection(event);
		if (!(selection.getFirstElement() instanceof IFile))
			return null;
		
		job("Generating Cinco Product.")
		  .consume(10)
			.task("Disabling auto-build...", this::disableAutoBuild)
		  	.task("Initializing...", this::init)
		    .task("Deleting generated resources...", this::deleteGeneratedResources)
		    .task("Collecting MGLs...", this::mglTopSort)
		    .task("Resetting registries...", this::resetRegistries)
		  
		  .consume(30)
			.taskForEach(() -> mgls.stream(), this::generateProductPart,
					t -> String.format("Generating %s.",t.getFullPath().lastSegment()))
		  
		  .consume(20)
			.task("Building workspace...", this::buildWorkspace)
		  		
//		  .consumeConcurrent(30)
//		    .taskForEach(mgls, this::buildGratext)
		  
		  .onFailed(() -> displayErrorDialog(event, reason))
		  .onDone(this::resetAutoBuild)
		  .onFinished(() -> displaySuccessDialog(event, startTime))
		.schedule();
	
//		}catch(Exception e1){
//
//			displayErrorDialog(event, e1);
//		}
		
		return null;
	}
	
	private void init() {
		commandService = (ICommandService) PlatformUI.getWorkbench().getService(ICommandService.class);
		cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
		cpd = resp(cpdFile).getResourceContent(CincoProduct.class, 0);
	}

	private void resetRegistries() {
		BundleRegistry.resetRegistry();
		MGLEPackageRegistry.resetRegistry();
	}

	private void displaySuccessDialog(ExecutionEvent event, long startTime) {
		long stopTime = System.nanoTime();
		System.err.println("Stopping at: "+stopTime);
		System.err.println(String.format("Generation took %s of your earth minutes.",(stopTime-startTime)*Math.pow(10,-9)/60));
		Display display = Display.getCurrent();
		if(display==null)
			display=Display.getDefault();
		
		display.syncExec(()->{MessageDialog.openInformation(HandlerUtil.getActiveShell(event), "Cinco Product Generation", "Cinco Product generation completed successfully");});
		
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

	private void generateProductPart(IFile mglFile) {
		
		MGLSelectionListener.INSTANCE.putMGLFile(mglFile);
		
		try {
			//System.out.println("Generating Ecore/GenModel from MGL...");
			execute("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
			
			//System.out.println("Generating Model Code from GenModel...");
			GeneratorHelper.generateGenModelCode(mglFile);
			
			//System.out.println("Generating Graphiti Editor...");
			execute("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
//				IProject apiProject = ResourcesPlugin.getWorkspace().getRoot().getProject(mglModelFile.getProject().getName().concat(".graphiti.api"));
			
			IProject apiProject = mglFile.getProject();
			if (apiProject.exists())
				GeneratorHelper.generateGenModelCode(apiProject, "C"+mglFile.getName().split("\\.")[0]);
			
			//System.out.println("Generating jABC4 Project Information");
			execute("de.jabc.cinco.meta.core.jabcproject.commands.generateCincoSIBsCommand");
			
			// TODO: Product definition should be made central file
			//System.out.println("Generating Product project");
			execute("cpd.handler.ui.generate");
			
			//System.out.println("Generating Feature Project");
			execute("de.jabc.cinco.meta.core.generatefeature");
			
			generateDefaultPerspective(mglFile);
			
			execute("de.jabc.cinco.meta.plugin.gratext.generategratext");
			
		} catch (ExecutionException | NotDefinedException | NotEnabledException
				| NotHandledException | IOException e) {
			reason = new RuntimeException(String.format("Generation of %s failed", cpdFile.getName()),e);
			throw reason;
		}
	}

	private void buildGratext(IFile mglFile) {
		try {
			
			execute("de.jabc.cinco.meta.plugin.gratext.buildgratext");
		
		} catch (ExecutionException | NotDefinedException | NotEnabledException | NotHandledException e) {
			throw new RuntimeException(String.format("Generation of %s failed", cpdFile.getName()), e);
		}
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
	
	private List<IFile> mglTopSort(){
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
		mgls = dg.topSort().stream().map(path -> cpdFile.getProject().getFile(path)).collect(Collectors.toList());
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
	
	private void generateDefaultPerspective(IFile mglFile) {
		CincoProduct cp = (CincoProduct) CincoUtils.getCPD(cpdFile);
		
		IProject p = cpdFile.getProject();
		IFile pluginXML = p.getFile("plugin.xml");
		String extensionCommentID = "<!--@CincoGen "+cp.getName().toUpperCase()+"-->";
		
		if (cp.getDefaultPerspective() != null && !cp.getDefaultPerspective().isEmpty())
			return;
		
		CharSequence defaultPerspectiveContent = 
				de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent.generateDefaultPerspective(cp, cpdFile.getProject().getName());
		CharSequence defaultXMLPerspectiveContent = 
				de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent.generateXMLPerspective(cp, cpdFile.getProject().getName());
		
		IFile file = p.getFile("src-gen/"+p.getName().replace(".", "/")+"/"+cp.getName()+"Perspective.java");
		CincoUtils.writeContentToFile(file, defaultPerspectiveContent.toString());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), defaultXMLPerspectiveContent.toString(), extensionCommentID, p.getName());
	}
	
	private void execute(String commandId) throws ExecutionException, NotDefinedException, NotEnabledException, NotHandledException {
		commandService.getCommand(commandId).executeWithChecks(event);
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
				System.out.println("[Gratext] WARN: Failed to reset state for \"Build Automatically\". "
						+ "Should be " + autoBuild);
				e.printStackTrace();
			}
		}
	}
	
	public void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	public void buildWorkspace() {
		try {
			ResourcesPlugin.getWorkspace().build(IncrementalProjectBuilder.FULL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	
}
