package de.jabc.cinco.meta.plugin.mcam;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.JavaCore;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;

public class MetaPluginMcam implements IMetaPlugin {

	private GraphModel gModel;

	private String basePackage = null;
	private String mcamPackageSuffix = McamImplementationGenerator.mcamPackageSuffix;
	private String conflictViewPackageSuffix = McamConflictViewGenerator.conflictViewPackageSuffix;

	private IProject mcamProject = null;
	private IProject mcamConflictViewProject = null;
	private NullProgressMonitor monitor = new NullProgressMonitor();
	private HashSet<IClasspathEntry> classpathEntries = new HashSet<>();

	public MetaPluginMcam() {
	}

	@Override
	public String execute(Map<String, Object> map) {

		System.out.println("------ Model-CaM Generation ------");

		gModel = (GraphModel) map.get("graphModel");
		this.basePackage = gModel.getPackage();

		System.out.println("Creating Mcam-Eclipse-Project...");
		mcamProject = createMcamEclipseProject();
		
		McamImplementationGenerator genMcam = new McamImplementationGenerator(
				gModel, mcamProject, basePackage);
		String result = genMcam.generate();
		
		System.out.println("Editing Manifest...");
		try {
			IFile iManiFile = mcamProject.getFolder("META-INF").getFile("MANIFEST.MF");
			Manifest manifest = new Manifest(iManiFile.getContents());
			
			String exportPackage = (String) genMcam.data.get("AdapterPackage");
			exportPackage = exportPackage + "," + (String) genMcam.data.get("CliPackage");
			exportPackage = exportPackage + "," + (String) genMcam.data.get("ChangeModulePackage");
			exportPackage = exportPackage + "," + (String) genMcam.data.get("StrategyPackage");
			
			manifest.getMainAttributes().putValue("Export-Package", exportPackage);
			
//			exportPackage(manifest, (String) gen.data.get("AdapterPackage"));
//			exportPackage(manifest, (String) gen.data.get("CliPackage"));
//			exportPackage(manifest, (String) gen.data.get("ChangeModulePackage"));
//			exportPackage(manifest, (String) gen.data.get("StrategyPackage"));

			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
			
			mcamProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			
			mcamProject.close(monitor);
			mcamProject.open(monitor);
		} catch (Exception e) {
			e.printStackTrace();
			return "error";
		}
		
		System.out.println("Creating ConflictView-Eclipse-Project...");
		mcamConflictViewProject = createConflictViewEclipseProject();
		
		McamConflictViewGenerator genConflictView = new McamConflictViewGenerator(gModel, mcamConflictViewProject, basePackage);
		genConflictView.generate();
		
		try {
			mcamConflictViewProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			
			mcamConflictViewProject.close(monitor);
			mcamConflictViewProject.open(monitor);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("----------------------------------");
		return result;
	}

	private IProject createMcamEclipseProject() {
		String projectName = basePackage + "." + mcamPackageSuffix;
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundlesForMcam();
		return ProjectCreator.createProject(projectName, srcFolders, null,
				reqBundles, null, null, monitor, cleanDirs, false);
	}
	
	private IProject createConflictViewEclipseProject() {
		String projectName = basePackage + "." + mcamPackageSuffix + "." + conflictViewPackageSuffix;
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundlesForConflictView();
		return ProjectCreator.createProject(projectName, srcFolders, null,
				reqBundles, null, null, monitor, cleanDirs, false);
	}

	private void exportPackage(Manifest manifest, String pkgName) throws IOException,
			CoreException {
		String exportPackage = manifest.getMainAttributes().getValue(
				"Export-Package");

		String newVal = pkgName;

		if (exportPackage != null) {
			String[] pkgs = exportPackage.split(", \n");
			boolean found = false;
			for (String s : pkgs) {
				if (s.equals(pkgName))
					found = true;
			}
			if (!found) {
				newVal = exportPackage + ", \n" + pkgName;
			}
		}
		manifest.getMainAttributes().putValue("Export-Package", newVal);
		
	}

	private void copyAndIncludeJar(String name) throws CoreException,
			IOException {
		IFolder folder = mcamProject.getFolder("lib");
		IFile file = folder.getFile(name);

		if (!folder.exists())
			folder.create(IResource.NONE, true, null);
		if (!file.exists()) {
			Bundle bundle = Platform
					.getBundle("de.jabc.cinco.meta.plugin.mcam");
			InputStream in = FileLocator.openStream(bundle, new Path("lib/"
					+ name), true);
			file.create(in, IResource.NONE, null);
		}

		classpathEntries.add(JavaCore.newLibraryEntry(new Path(file
				.getLocation().toString()), // library location
				null, // source archive location
				null, // source archive root path
				true) // exported
				);
	}

	// private String executeWithJabc() {
	// LightweightExecutionContext context = new
	// DefaultLightweightExecutionContext(
	// null);
	// context.put("graphModel", gModel);
	// LightweightExecutionEnvironment env = new
	// DefaultLightweightExecutionEnvironment(
	// context);
	//
	// try {
	// Main mainGraph = new Main();
	// String result = mainGraph.execute(env);
	// if (result.equals("error")) {
	// Exception e = (Exception) context.get("exception");
	// throw new ExecutionException(e.getMessage());
	//
	// }
	// p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
	//
	// } catch (CoreException e) {
	// e.printStackTrace();
	// return "error";
	// } catch (ExecutionException e1) {
	// e1.printStackTrace();
	// return "error";
	// }
	//
	// return "default";
	// }
	
	private Set<String> getReqBundlesForMcam() {
		HashSet<String> reqBundles = new HashSet<String>();

		reqBundles.add("org.eclipse.core.runtime");
		reqBundles.add("de.jabc.cinco.meta.core.mgl.model");
		reqBundles.add("org.eclipse.graphiti.mm");
		reqBundles.add(basePackage);
		reqBundles.add("de.jabc.cinco.meta.plugin.mcam.libs");
		reqBundles.add("de.jabc.cinco.meta.core.ge.style.model");

		return reqBundles;
	}

	private Set<String> getReqBundlesForConflictView() {
		HashSet<String> reqBundles = new HashSet<String>();

		//reqBundles.add("de.jabc.cinco.meta.plugin.mcam.libs");

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
		cleanDirs.add("src-gen");
		return cleanDirs;
	}
	
}
