package de.jabc.cinco.meta.plugin.mcam;

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

import de.jabc.cinco.meta.core.BundleRegistry;
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
		String result = "";

		BundleRegistry.INSTANCE.addBundle("de.jabc.cinco.meta.plugin.mcam",
				true);
		BundleRegistry.INSTANCE.addBundle(
				"de.jabc.cinco.meta.plugin.mcam.runtime", false);

		gModel = (GraphModel) map.get("graphModel");
		System.out.println("------ Model-CaM Generation for '"
				+ gModel.getName() + "' ------");

		/*
		 * get packages / project
		 */
		this.modelPackage = gModel.getPackage();
		String[] path = gModel.eResource().getURI().path().split("/");
		this.modelProjectName = path[2];
		IProject mcamProject = ResourcesPlugin.getWorkspace().getRoot()
				.getProject(modelProjectName);

		if (mcamProject == null)
			return "error";

		/*
		 * create mcam implementation
		 */
		McamImplementationGenerator genMcam = new McamImplementationGenerator(
				gModel, mcamProject, modelPackage, modelProjectName);
		try {
			IFolder f = mcamProject.getFolder("src-gen" + "/"
					+ genMcam.getMcamProjectBasePackage().replace(".", "/"));
			if (f != null && f.exists())
				cleanDirectory(f);
			mcamProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		}
		result = genMcam.generate();

		/*
		 * write new manifest
		 */
		System.out.println("Editing Manifest...");
		try {
			writeExportedPackagesToManifest(mcamProject, genMcam);
			writeRequiredBundlesToManifest(mcamProject, genMcam);
			mcamProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
			return "error";
		}

		/*
		 * create view project
		 */
		System.out.println("Creating MCaM-View-Eclipse-Project...");
		IProject mcamViewProject = createMcamViewEclipseProject();

		/*
		 * create view implementation
		 */
		McamViewGenerator genView = new McamViewGenerator(gModel,
				mcamViewProject, modelPackage, modelProjectName, genMcam);
		try {
			IFolder f = mcamViewProject.getFolder("src-gen" + "/"
					+ genView.getMcamViewPackage().replace(".", "/"));
			if (f != null && f.exists())
				cleanDirectory(f);
			mcamViewProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		}
		result = genView.generate();

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
			McamImplementationGenerator genMcam) throws IOException,
			CoreException {
		IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest = new Manifest(iManiFile.getContents());

		String exportPackage = (String) genMcam.data.get("AdapterPackage");
		exportPackage = exportPackage + ","
				+ (String) genMcam.data.get("CliPackage");
		if (genMcam.doGenerateMerge())
			exportPackage = exportPackage + ","
					+ (String) genMcam.data.get("ChangeModulePackage");

		manifest.getMainAttributes().putValue(
				"Export-Package",
				cleanManifestAttribute(
						getManifestAttribute(project, "Export-Package"),
						genMcam.getMcamProjectBasePackage()) + exportPackage);

		manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
	}

	private void writeRequiredBundlesToManifest(IProject project,
			McamImplementationGenerator genMcam) throws IOException,
			CoreException {
		IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest = new Manifest(iManiFile.getContents());

		String exportPackage = "de.jabc.cinco.meta.plugin.mcam.runtime"; // ;visibility:=reexport";

		manifest.getMainAttributes().putValue(
				"Require-Bundle",
				cleanManifestAttribute(
						getManifestAttribute(project, "Require-Bundle"),
						"de.jabc.cinco.meta.plugin.mcam.runtime")
						+ exportPackage);

		manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
	}

	private String getManifestAttribute(IProject project, String attrName)
			throws IOException, CoreException {
		IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF");
		if (!iManiFile.exists())
			return "";
		Manifest manifest;
		manifest = new Manifest(iManiFile.getContents());
		return manifest.getMainAttributes().getValue(attrName);
	}

	private String cleanManifestAttribute(String values,
			String packagePrefixToClean) {
		String output = "";
		if (values == null)
			return output;
		String[] epEntries = values.split(",");
		for (String entry : epEntries) {
			if (entry.startsWith(packagePrefixToClean))
				continue;
			if (entry.equals("null"))
				continue;
			if (entry.length() <= 0)
				continue;
			output += entry + ",";
		}
		return output;
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
		reqBundles.add("de.jabc.cinco.meta.plugin.mcam.runtime");

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
