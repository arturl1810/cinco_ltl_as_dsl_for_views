package de.jabc.cinco.meta.plugin.mcam;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.jar.Manifest;

import mgl.GraphModel;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;

public class MetaPluginMcam implements IMetaPlugin {

	private GraphModel gModel;

	private String modelPackage = null;
	private String modelProjectName = null;
	private String mcamPackageSuffix = McamImplementationGenerator.mcamPackageSuffix;
	private String mcamViewPackageSuffix = McamViewGenerator.viewPackageSuffix;

	private NullProgressMonitor monitor = new NullProgressMonitor();

	public MetaPluginMcam() {
	}

	@Override
	public String execute(Map<String, Object> map) {
		gModel = (GraphModel) map.get("graphModel");
		System.out.println("------ Model-CaM Generation for '"
				+ gModel.getName() + "' ------");
		
		
		this.modelPackage = gModel.getPackage();
		String[] path = gModel.eResource().getURI().path().split(File.separator);
		this.modelProjectName = path[2];
		IProject mcamProject = ResourcesPlugin.getWorkspace().getRoot().getProject(modelProjectName);
		
		if (mcamProject == null)
			return "error";
		
		/*
		 * get old exported Packages
		 */
		String oldEP = "";
		try {
			oldEP = getExportedPackages(mcamProject);
		} catch (CoreException | IOException e) {
			e.printStackTrace();
			return "error";
		}

		/*
		 * create mcam project
		 */
//		System.out.println("Creating Mcam-Eclipse-Project...");
//		IProject mcamProject = createMcamEclipseProject();

		/*
		 * create mcam implementation
		 */
		McamImplementationGenerator genMcam = new McamImplementationGenerator(
				gModel, mcamProject, modelPackage, modelProjectName);
		try {
			IFolder f = mcamProject.getFolder("src-gen" + File.separator
					+ genMcam.getMcamProjectBasePackage().replace(".", File.separator));
			if (f != null && f.exists())
				cleanDirectory(f);
			mcamProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		}
		String result = genMcam.generate();

		/*
		 * write new manifest
		 */
		System.out.println("Editing Manifest...");
		try {
			writeExportedPackagesToManifest(mcamProject, genMcam, oldEP);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
			return "error";
		}

		/*
		 * refresh project
		 */
		try {
			mcamProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			mcamProject.close(monitor);
			mcamProject.open(monitor);
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		}
		
		/*
		 *  create view project
		 */
		System.out.println("Creating MCaM-View-Eclipse-Project...");
		IProject mcamViewProject = createMcamViewEclipseProject();

		/*
		 * create view implementation
		 */
		McamViewGenerator genView = new McamViewGenerator(gModel,
				mcamViewProject, modelPackage, modelProjectName, genMcam);
		try {
			IFolder f = mcamViewProject.getFolder("src-gen" + File.separator
					+ genView.getMcamViewPackage().replace(".", File.separator));
			if (f != null && f.exists())
				cleanDirectory(f);
			mcamViewProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		}
		genView.generate();

		try {
			mcamViewProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);

			mcamViewProject.close(monitor);
			mcamViewProject.open(monitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}

		System.out.println("----------------------------------");
		return result;
	}

	private IProject createMcamEclipseProject() {
		String projectName = modelProjectName + "." + mcamPackageSuffix;
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundlesForMcam();
		return ProjectCreator.createProject(projectName, srcFolders, null,
				reqBundles, null, null, monitor, cleanDirs, false);
	}

	private IProject createMcamViewEclipseProject() {
		String projectName = modelProjectName + "." + mcamPackageSuffix + "."
				+ mcamViewPackageSuffix;
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundlesForView();
		return ProjectCreator.createProject(projectName, srcFolders, null,
				reqBundles, null, null, monitor, cleanDirs, false);
	}

	private void writeExportedPackagesToManifest(IProject project,
			McamImplementationGenerator genMcam, String oldEP)
			throws IOException, CoreException {
		IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest = new Manifest(iManiFile.getContents());

		String exportPackage = (String) genMcam.data.get("AdapterPackage");
		exportPackage = exportPackage + ","
				+ (String) genMcam.data.get("CliPackage");
		if (genMcam.doGenerateMerge())
			exportPackage = exportPackage + ","
					+ (String) genMcam.data.get("ChangeModulePackage");
		exportPackage = exportPackage + ","
				+ (String) genMcam.data.get("StrategyPackage");
		exportPackage = exportPackage + ","
				+ (String) genMcam.data.get("UtilPackage");

		manifest.getMainAttributes().putValue(
				"Export-Package",
				cleanExportedPackages(oldEP, genMcam.getMcamProjectBasePackage())
						+ exportPackage);

		manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
	}

	private String getExportedPackages(IProject project) throws CoreException, IOException {
		IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF");
		if (!iManiFile.exists())
			return "";
		Manifest manifest = new Manifest(iManiFile.getContents());
		return manifest.getMainAttributes().getValue("Export-Package");
	}

	private String cleanExportedPackages(String ep, String packagePrefix) {
		String epOutput = "";
		if (ep == null)
			return epOutput;
		String[] epEntries = ep.split(",");
		for (String entry : epEntries) {
			if (entry.startsWith(packagePrefix))
				continue;
			if (entry.equals("null"))
				continue;
			if (entry.length() <= 0)
				continue;
			epOutput += entry + ",";
		}
		return epOutput;
	}

	private void cleanDirectory(IFolder folder) throws CoreException {
		if (!folder.exists())
			return;
		for (IResource res : folder.members()) {
			if (res instanceof IFolder)
				cleanDirectory((IFolder) res);
			if (res instanceof IFile)
				res.delete(true, monitor);
		}
		folder.delete(true, monitor);
	}

	// private void copyAndIncludeJar(String name) throws CoreException,
	// IOException {
	// IFolder folder = mcamProject.getFolder("lib");
	// IFile file = folder.getFile(name);
	//
	// if (!folder.exists())
	// folder.create(IResource.NONE, true, null);
	// if (!file.exists()) {
	// Bundle bundle = Platform
	// .getBundle("de.jabc.cinco.meta.plugin.mcam");
	// InputStream in = FileLocator.openStream(bundle, new Path("lib/"
	// + name), true);
	// file.create(in, IResource.NONE, null);
	// }
	//
	// classpathEntries.add(JavaCore.newLibraryEntry(new Path(file
	// .getLocation().toString()), // library location
	// null, // source archive location
	// null, // source archive root path
	// true) // exported
	// );
	// }

	private Set<String> getReqBundlesForMcam() {
		HashSet<String> reqBundles = new HashSet<String>();

		reqBundles.add("org.eclipse.core.runtime");
		reqBundles.add("de.jabc.cinco.meta.core.mgl.model");
		reqBundles.add("org.eclipse.graphiti.mm");
		reqBundles.add(modelProjectName);
		reqBundles.add("de.jabc.cinco.meta.core.ge.style.model");
		reqBundles.add("de.jabc.cinco.meta.libraries");
		reqBundles.add("org.apache.commons.cli");

		return reqBundles;
	}

	private Set<String> getReqBundlesForView() {
		HashSet<String> reqBundles = new HashSet<String>();
		return reqBundles;
	}

	private List<String> getSrcFolders() {
		ArrayList<String> folders = new ArrayList<String>();
		folders.add("src");
		folders.add("src-gen");
		return folders;
	}

	private List<String> getCleanDirectory() {
		ArrayList<String> cleanDirs = new ArrayList<String>();
		// cleanDirs.add("src-gen");
		return cleanDirs;
	}

}
