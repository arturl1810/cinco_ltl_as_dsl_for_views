package de.jabc.cinco.meta.core.ui.handlers;

import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.LinkedList;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;
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
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.mgl.MGLEPackageRegistry;
import de.jabc.cinco.meta.core.pluginregistry.CPDAnnotation;
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
import de.jabc.cinco.meta.util.xapi.FileExtension;
import mgl.GraphModel;
import mgl.Import;
import mgl.MglPackage;
import productDefinition.CincoProduct;
import productDefinition.MGLDescriptor;
import transem.utility.helper.Tuple;
import org.eclipse.xtext.xbase.lib.Pair;

/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * 
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
@SuppressWarnings("restriction")
public class CincoProductGenerationHandler extends AbstractHandler {

	private Long lastGenerationTime = 0L;

	ICommandService commandService;
	private RuntimeException reason;
	private List<IFile> allMGLs;
	private List<IFile> generateMGLs;
	private List<IFile> ignoredMGLs;
	private IFile cpdFile;
	private CincoProduct cpd;
	private ExecutionEvent event;
	private boolean autoBuild;

	private FileExtension fileHelper;

	/**
	 * The constructor.
	 */
	public CincoProductGenerationHandler() {
	}

	/**
	 * the command has been executed, so extract the needed information from the
	 * application context and run the build job.
	 */
	synchronized public Object execute(ExecutionEvent executionEvent) throws ExecutionException {
		long startTime = System.nanoTime();
		this.event = executionEvent;

		/*
		 * INITIALIZATION
		 */
		this.readCPDFile();
		this.readGenerationTimestamp();
		this.calculateMGL_Sets();
		
		if (generateMGLs.size() == 0) {
			Display display = getDisplay();
			if (MessageDialog.openQuestion(display.getActiveShell(), "Cinco Product Generator",
					"No model changes! \n \n Generate anyways? :-$")) {
				deleteGenerationTimestamp();
				calculateMGL_Sets();
			} else {
				return null;
			}
		}

		/*
		 * SET UP
		 */
		Workload job = job("Generate Cinco Product").consume(10, "Initializing...")
				.task("Disabling auto-build...", this::disableAutoBuild);
		
		/*
		 * MGL PREPROCESSING
		 */
		if (generateMGLs.size() > 0) {
			job.task("Deleting previously generated resources...", this::deleteGeneratedResources);
		}
		
		
		// FIXME this should be put to a CPDMetaPlugin as soon as the plugin
				// structure has been fixed.
//		final Map<IFile, IFile> backuppedMGLs = new HashMap<IFile, IFile>();
//		job.consume(20, "Preprocessing MGLs...").task(() -> backuppedMGLs.putAll(preprocessMGLs(generateMGLs)));

		/*
		 * MGL TASKS
		 */
		// TODO this could be much nicer with nested jobs or JOOL/Seq and Xtend
		job.consume(50 * generateMGLs.size(), "Processing MGLs")
				.taskForEach(() -> generateMGLs.stream().flatMap(file -> {
					final List<Pair<String, Runnable>> pairs = new LinkedList<>();
					pairs.add(new Pair<>(String.format("%s: Deleting Ressources... ", file.getFullPath().lastSegment()),
							() -> deleteGeneratedMGLResources(file)));
					pairs.add(new Pair<>(String.format("%s: Initializing...", file.getFullPath().lastSegment()),
							() -> publishMglFile(file)));
					pairs.add(
							new Pair<>(String.format("%s: Generating Ecore/GenModel...", file.getFullPath().lastSegment()),
									() -> generateEcoreModel(file)));
					pairs.add(new Pair<>(String.format("%s: Generating model code...", file.getFullPath().lastSegment()),
							() -> generateGenmodelCode(file)));
					pairs.add(
							new Pair<>(String.format("%s: Generating Graphiti editor...", file.getFullPath().lastSegment()),
									() -> generateGraphitiEditor(file)));
					pairs.add(new Pair<>(String.format("%s: Generating API...", file.getFullPath().lastSegment()),
							() -> generateApi(file)));
					pairs.add(new Pair<>(String.format("%s: Generating Cinco SIBs...", file.getFullPath().lastSegment()),
							() -> generateCincoSIBs(file)));
					pairs.add(
							new Pair<>(String.format("%s: Generating product project...", file.getFullPath().lastSegment()),
									() -> generateProductProject(file)));
					pairs.add(
							new Pair<>(String.format("%s: Generating feature project...", file.getFullPath().lastSegment()),
									() -> generateFeatureProject(file)));
					pairs.add(new Pair<>(String.format("%s: Generating perspective...", file.getFullPath().lastSegment()),
							() -> generatePerspective(file)));
					pairs.add(new Pair<>(String.format("%s: Generating Gratext model...", file.getFullPath().lastSegment()),
							() -> {
								if (isGratextEnabled())
									generateGratextModel(file);
							}));
					return pairs.stream();
				}), pair -> pair.getValue().run(), pair -> pair.getKey());

		/*
		 * BUILD GRATEXT
		 */
		if (isGratextEnabled()) {
			job.consumeConcurrent(60 * generateMGLs.size(), "Building Gratext...")
					.taskForEach(() -> generateMGLs.stream(), this::buildGratext, t -> t.getFullPath().lastSegment());
		}

		/*
		 * CPD TASKS
		 */
		if (generateMGLs.size() > 0) {
			job.task("Generate CPD plugins", () -> generateCPDPlugins(allMGLs));
		}

		/*
		 * GLOBAL TASKS
		 */
		if (generateMGLs.size() > 0) {
			job.consume(5, "Global Processing").task("Generating project wizard...", this::generateProjectWizard);
		}

		/*
		 * START JOBS
		 */
		job.onCanceledShowMessage("Cinco Product generation has been canceled").onFinished(() -> {
			writeGenerationTimestamp();
			printDebugOutput(event, startTime);
		}).onFinishedShowMessage("Cinco Product generation completed successfully").onDone(() -> resetAutoBuild())
				.schedule();

		return null;
	}

	private Display getDisplay() {
		return Display.getCurrent() != null ? Display.getCurrent() : Display.getDefault();
	}

	/**
	 * backups all provided MGLs and afterwards applies the preprocessing meta
	 * plug-in to the original files (potentially changing them). The returned
	 * map provides the reference to the backups for later restore.
	 * 
	 * @param mgls
	 * @return The MGL backups for later restore; key=backup value=(changed)
	 *         original.
	 */
	private Map<IFile, IFile> preprocessMGLs(List<IFile> mgls) {

		try {

			Map<IFile, IFile> backups = new HashMap<IFile, IFile>();

			IFolder backupFolder = mgls.get(0).getProject().getFolder("mgl-backups");
			if (!backupFolder.exists())
				backupFolder.create(false, false, null);

			mgls.stream().forEach(mgl -> {
				IFile targetFile = backupFolder.getFile(mgl.getName());
				try {
					if (targetFile.exists())
						targetFile.delete(true, null);
					mgl.copy(targetFile.getFullPath(), true, null);
					backups.put(targetFile, mgl);
				} catch (Exception e) {
					e.printStackTrace();
					throw new RuntimeException(e);
				}
			});

			FileExtension fileHelper = new FileExtension();
			final Set<GraphModel> graphModels = new LinkedHashSet<>(
					mgls.stream().map(n -> fileHelper.getContent(n, GraphModel.class)).collect(Collectors.toList()));

			new CPDPreprocessorPlugin().execute(graphModels, cpd, cpdFile.getProject());

			graphModels.stream().map(gm -> gm.eResource()).forEach(res -> {
				try {
					res.save(null);
				} catch (Exception e) {
					e.printStackTrace();
					throw new RuntimeException(e);
				}
			});

			return backups;

		} catch (RuntimeException e) {
			throw e;
		} catch (Throwable t) {
			t.printStackTrace();
			throw new RuntimeException(t);
		}

	}

	/**
	 * Executes the CPD meta plug ins
	 * 
	 * @param mgls
	 */
	private void generateCPDPlugins(List<IFile> mgls) {
		
		System.out.println("Generating CPD Plugins");

		Set<GraphModel> graphModels = mgls.stream().map(n -> fileHelper.getContent(n, GraphModel.class))
				.collect(Collectors.toSet());
		PluginRegistry.getInstance().getPluginCPDGenerators().stream()
				.filter(n -> cpd.getAnnotations().stream().filter(e -> e.getName().equals(n.getAnnotationName()))
						.findAny().isPresent())
				.forEach(n -> n.getPlugin().execute(graphModels, cpd, cpdFile.getProject()));
	}

	private void readCPDFile() {

		commandService = (ICommandService) PlatformUI.getWorkbench().getService(ICommandService.class);
		cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();

		if (!(cpdFile instanceof IFile))
			throw new RuntimeException("No valid CPD fFile selected!");

		fileHelper = new FileExtension();
		cpd = fileHelper.getContent(cpdFile, CincoProduct.class, 0);
		MGLSelectionListener.INSTANCE.setCurrentCPD(cpd);
	}

	private void resetRegistries() {
		BundleRegistry.resetRegistry();
		MGLEPackageRegistry.resetRegistry();

	}

	private void printDebugOutput(ExecutionEvent event, long startTime) {
		long stopTime = System.nanoTime();
		System.err.println("Stopping at: " + stopTime);
		System.err.println(String.format("Generation took %s of your earth minutes.",
				(stopTime - startTime) * Math.pow(10, -9) / 60));
	}

	private void publishMglFile(IFile mglFile) {
		MGLSelectionListener.INSTANCE.putMGLFile(mglFile);
	}

	private void generateEcoreModel(IFile mglFile) {
		execute("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
	}

	private void generateGenmodelCode(IFile mglFile) {
		try {
			GeneratorHelper.generateGenModelCode(mglFile);
		} catch (IOException e) {
			reason = new RuntimeException(String.format("Generation of %s failed", mglFile.getFullPath().lastSegment()),
					e);
			throw reason;
		}
	}

	private void generateGraphitiEditor(IFile mglFile) {
		execute("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
	}

	private void generateApi(IFile mglFile) {
		IProject apiProject = mglFile.getProject();
		if (apiProject.exists())
			try {
				GeneratorHelper.generateGenModelCode(apiProject, "C" + mglFile.getName().split("\\.")[0]);
			} catch (IOException e) {
				reason = new RuntimeException(
						String.format("Generation of %s failed", mglFile.getFullPath().lastSegment()), e);
				throw reason;
			}
	}

	private void generateCincoSIBs(IFile mglFile) {
		execute("de.jabc.cinco.meta.core.jabcproject.commands.generateCincoSIBsCommand");
	}

	private void generateProductProject(IFile mglFile) {
		execute("cpd.handler.ui.generate");
	}

	private void generateFeatureProject(IFile mglFile) {
		execute("de.jabc.cinco.meta.core.generatefeature");
	}

	private void generatePerspective(IFile mglFile) {
		generateDefaultPerspective(mglFile);
	}

	private void generateGratextModel(IFile mglFile) {
		if (isGratextEnabled()) {
			execute("de.jabc.cinco.meta.plugin.gratext.generategratext");
		}
	}

	private void buildGratext(IFile mglFile) {
		if (isGratextEnabled()) {
			execute("de.jabc.cinco.meta.plugin.gratext.buildgratext");
		}
	}

	private boolean isGratextEnabled() {
		return cpd.getAnnotations().stream().noneMatch(ann -> "disableGratext".equals(ann.getName()));
	}

	private EObject loadModel(IFile cpdFile, String fileExtension, EPackage ePkg) throws IOException, CoreException {
		URI createPlatformResourceURI = URI.createPlatformResourceURI(cpdFile.getFullPath().toPortableString(), true);
		Resource res = Resource.Factory.Registry.INSTANCE.getFactory(createPlatformResourceURI, fileExtension)
				.createResource(createPlatformResourceURI);
		// ResourceSet set = ePkg.eResource().getResourceSet();
		res.load(cpdFile.getContents(), null);
		return res.getContents().get(0);
	}

	private void deleteGeneratedResources() {
		IProject project = cpdFile.getProject();
		try {
			Collection<IResource> toDelete = new ArrayList<>();
			toDelete.add(project.findMember("resources-gen/"));
			for (IResource resource : toDelete) {
				if (resource != null) {
					resource.delete(org.eclipse.core.resources.IResource.FORCE, null);
				}
			}

		} catch (CoreException e) {
			throw new RuntimeException(e);
		}
	}
	
	private void deleteGeneratedMGLResources(IFile mglFile) {
		IProject project = cpdFile.getProject();
		try {
			EObject eObj = loadModel(mglFile, "mgl", MglPackage.eINSTANCE);

			if (eObj instanceof GraphModel) {
				String gmPackage = ((GraphModel) eObj).getPackage();
			
				IFolder packageFolder = project.getFolder("src-gen/" + toPath(gmPackage));
				if (packageFolder.exists()) {
					packageFolder.delete(org.eclipse.core.resources.IResource.FORCE, null);
				}
			}
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (CoreException e) {
			throw new RuntimeException(e);
		}
		
	}

	private void calculateMGL_Sets() {
		this.resetRegistries();
		IProject project = cpdFile.getProject();
		List<DependencyNode> dns = new ArrayList<DependencyNode>();
		this.ignoredMGLs = new ArrayList<>();

		for (MGLDescriptor mgl : cpd.getMgls()) {
			String mglPath = mgl.getMglPath();
			IFile mglFile = project.getFile(mglPath);

			try {
				EObject eObj = loadModel(mglFile, "mgl", MglPackage.eINSTANCE);
				if (eObj instanceof GraphModel) {
					GraphModel gm = (GraphModel) eObj;
					String projectSymbolicName = ProjectCreator.getProjectSymbolicName(project);
					DependencyNode dn = new DependencyNode(gm.eResource().getURI().toPlatformString(true)
							.replace("/" + projectSymbolicName + "/", ""));
					for (Import imprt : gm.getImports()) {
						if (imprt.getImportURI().endsWith(".mgl")) {
							if (!imprt.isStealth()) {
								String importStr = imprt.getImportURI()
										.replace("platform:/resource/" + projectSymbolicName + "/", "");
								if (importStr.startsWith("/"))
									importStr = importStr.substring(1);
								dn.getDependsOf().add(importStr);
							}
						}
					}
					dns.add(dn);
				}
			} catch (IOException | CoreException e) {

				e.printStackTrace();
			}

			if (!isGenerationRequired(getIFileforMGL(mgl))) {
				this.ignoredMGLs.add(getIFileforMGL(mgl));
				MGLEPackageRegistry.INSTANCE.addMGLEPackage(getEPackageForMGL(mglFile, project));
			}
			

		}

		DependencyGraph dg = DependencyGraph.createGraph(dns);
		List<IFile> topSortMGLs = dg.topSort().stream().map(path -> cpdFile.getProject().getFile(path))
				.collect(Collectors.toList());
		
		this.allMGLs = new ArrayList<IFile>(topSortMGLs);
		topSortMGLs.removeAll(this.ignoredMGLs);
		this.generateMGLs = topSortMGLs;
	}

	private EPackage getEPackageForMGL(IFile mglFile, IProject project) {
		String ecoreName = mglFile.getName().replace(mglFile.getFileExtension(), "ecore");
		// String ecorePath = project.getFile("src-gen/model/" +
		// ecoreName).getProjectRelativePath().makeAbsolute()
		// .toString();
		URI uri = URI.createPlatformResourceURI(
				ProjectCreator.getProjectSymbolicName(project) + "/src-gen/model/" + ecoreName, true);
		Resource res = Resource.Factory.Registry.INSTANCE.getFactory(uri).createResource(uri);
		try {
			res.load(null);
			return (EPackage) res.getContents().get(0);
		} catch (IOException e) {

			throw new RuntimeException("Failed to load ecore model: " + ecoreName, e);
		}
	}

	private String toPath(String e) {
		return e.replace('.', '/');
	}

	private void generateDefaultPerspective(IFile mglFile) {
		CincoProduct cp = (CincoProduct) CincoUtils.getCPD(cpdFile);

		IProject p = cpdFile.getProject();
		IFile pluginXML = p.getFile("plugin.xml");
		String extensionCommentID = "<!--@CincoGen " + cp.getName().toUpperCase() + "-->";

		if (cp.getDefaultPerspective() != null && !cp.getDefaultPerspective().isEmpty())
			return;

		CharSequence defaultPerspectiveContent = de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent
				.generateDefaultPerspective(cp, cpdFile);
		CharSequence defaultXMLPerspectiveContent = de.jabc.cinco.meta.core.ui.templates.DefaultPerspectiveContent
				.generateXMLPerspective(cp, cpdFile.getProject().getName());

		IFile file = p.getFile("src-gen/" + p.getName().replace(".", "/") + "/" + cp.getName() + "Perspective.java");
		CincoUtils.writeContentToFile(file, defaultPerspectiveContent.toString());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), defaultXMLPerspectiveContent.toString(),
				extensionCommentID, p.getName());
	}

	private void execute(String commandId) {
		try {
			commandService.getCommand(commandId).executeWithChecks(event);
		} catch (ExecutionException | NotDefinedException | NotEnabledException | NotHandledException e) {
			IFile mglFile = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
			reason = (mglFile != null)
					? new RuntimeException(
							String.format("Generation of %s failed", mglFile.getFullPath().lastSegment()), e)
					: new RuntimeException(String.format("Generation of %s failed", cpdFile.getName()), e);
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
				System.err.println("[Gratext] WARN: Failed to reset state for \"Build Automatically\". " + "Should be "
						+ autoBuild);
				e.printStackTrace();
			}
		}
	}

	/**
	 * used to restore MGL backups: copies every key IFile to the according
	 * value IFile, deletes the key IFile and also each key IFile's parent
	 * folder, if it is empty (e.g. when the last backup is restored)
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
		String wizardExtensionCommentID = "<!--@CincoGen PROJECT_WIZARD_" + cp.getName().toUpperCase() + "_WIZ -->";
		String navigatorExtensionCommentID = "<!--@CincoGen PROJECT_WIZARD_" + cp.getName().toUpperCase() + "_NAV -->";

		CharSequence wizardJavaCode = NewProjectWizardGenerator.generateWizardJavaCode(cp,
				cpdFile.getProject().getName());
		CharSequence newWizardXML = NewProjectWizardGenerator.generateNewWizardXML(cp, cpdFile.getProject().getName(),
				wizardExtensionCommentID);
		CharSequence navigatorXML = NewProjectWizardGenerator.generateNavigatorXML(cp, cpdFile.getProject().getName(),
				navigatorExtensionCommentID);

		IFile file = p.getFile("src-gen/" + p.getName().replace(".", "/") + "/" + cp.getName() + "ProjectWizard.java");
		CincoUtils.writeContentToFile(file, wizardJavaCode.toString());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), newWizardXML.toString(), wizardExtensionCommentID,
				p.getName());
		CincoUtils.addExtension(pluginXML.getLocation().toString(), navigatorXML.toString(),
				navigatorExtensionCommentID, p.getName());
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

	private void readGenerationTimestamp() {
		String targetFilePath = getFilePath(cpdFile);
		if (targetFilePath == null) {
			lastGenerationTime = 0L;
			return;
		}

		File fname = new File(targetFilePath);
		if (!fname.exists()) {
			lastGenerationTime = 0L;
			return;
		}

		String line = null;
		StringBuilder stringBuilder = new StringBuilder();
		// String ls = System.getProperty("line.separator");

		BufferedReader reader;
		try {
			reader = new BufferedReader(new FileReader(targetFilePath));
			while ((line = reader.readLine()) != null) {
				stringBuilder.append(line);
				// stringBuilder.append(ls);
			}
			lastGenerationTime = Long.parseLong(stringBuilder.toString());
			reader.close();
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void writeGenerationTimestamp() {
		String targetFilePath = getFilePath(cpdFile);
		File fname = new File(targetFilePath);

		deleteGenerationTimestamp();

		try {
			fname.getParentFile().mkdirs();
			fname.createNewFile();
			Writer file = new FileWriter(fname);
			file.write(Long.toString(System.currentTimeMillis()));
			file.flush();
			file.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void deleteGenerationTimestamp() {
		String targetFilePath = getFilePath(cpdFile);
		File fname = new File(targetFilePath);
		fname.delete();
		lastGenerationTime = 0L;
	}

	public static String getFilePath(IFile file) {
		String sep = File.separator;
		String folderPath = file.getProject().getLocation().toFile().toString() + sep + "src-gen" + sep + "model";
		String filename = file.getName() + ".generated";
		return folderPath + sep + filename;
	}

	private boolean hasChanged(File file) {
		if (lastGenerationTime <= 0)
			return true;
		if (file.lastModified() > lastGenerationTime)
			return true;
		return false;
	}

	private IFile getIFileforMGL(MGLDescriptor mgl) {
		return cpdFile.getProject().getFile(mgl.getMglPath());
	}

	private boolean isGenerationRequired(IFile mglFile) {
		String mglPath = mglFile.getLocation().toString()
				.replace(mglFile.getProject().getLocation().toString() + File.separator, "");
		fileHelper = new FileExtension();
		GraphModel mgl = fileHelper.getContent(mglFile, GraphModel.class, 0);

		for (MGLDescriptor mglDesc : cpd.getMgls()) {
			String mglDescPath = mglDesc.getMglPath();
			if (!mglPath.equals(mglDescPath))
				continue;

			if (mglDesc.isForceGenerate())
				return true;

			if (mglDesc.isDontGenerate())
				return false;
		}

		if (hasChanged(mglFile.getLocation().toFile())) {
			System.out.println("MGL '" + mglFile.getName() + "' changed! Generation required");
			return true;
		}

		List<String> styles = new ArrayList<String>();
		String projectPath = mglFile.getProject().getLocation().toFile().toString();

		mgl.getAnnotations().stream().filter((ann -> "style".equals(ann.getName())))
				.forEach(ann -> styles.add(ann.getValue().get(0)));

		for (String stylePathString : styles) {
			File styleFile = new File(projectPath + File.separator + stylePathString);
			if (styleFile.exists()) {
				if (hasChanged(styleFile)) {
					System.out.println("Style '" + styleFile.getName() + "'changed! Generation for MGL '"
							+ mglFile.getName() + "'required");
					return true;
				}
			}
		}
		return false;
	}

}
