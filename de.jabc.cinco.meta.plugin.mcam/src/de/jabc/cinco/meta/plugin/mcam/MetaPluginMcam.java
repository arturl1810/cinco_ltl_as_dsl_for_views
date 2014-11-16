package de.jabc.cinco.meta.plugin.mcam;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;

public class MetaPluginMcam implements IMetaPlugin {

	private GraphModel gModel;

	private String basePackage = null;
	private String mcamPackageSuffix = ".mcam";

	private IProject p = null;
	private NullProgressMonitor monitor = new NullProgressMonitor();
	private HashSet<IClasspathEntry> classpathEntries = new HashSet<>();

	public MetaPluginMcam() {
	}

	@Override
	public String execute(Map<String, Object> map) {

		System.out.println("------ Model-CaM Generation ------");

		gModel = (GraphModel) map.get("graphModel");
		this.basePackage = gModel.getPackage();

		System.out.println("Creating Eclipse-Project...");
		createEclipseProject();
		try {
			copyAndIncludeJar("mcam-framework.jar");
			copyAndIncludeJar("commons-cli-1.1.jar");

			IJavaProject javaProject = JavaCore.create(p);
			IClasspathEntry[] oldClassPath = javaProject.getRawClasspath();
			for (IClasspathEntry iClasspathEntry : oldClassPath) {
				classpathEntries.add(iClasspathEntry);
			}
			IClasspathEntry[] arrayClassPath = new IClasspathEntry[classpathEntries.size()];
			arrayClassPath = classpathEntries.toArray(arrayClassPath);
			
			javaProject.setRawClasspath(arrayClassPath, monitor);
		} catch (Exception e) {
			e.printStackTrace();
			return "error";
		}

		// String result = executeWithJabc();
		McamImplementationGenerator gen = new McamImplementationGenerator(
				gModel, p, basePackage, mcamPackageSuffix);
		String result = gen.generate();

		System.out.println("----------------------------------");
		return result;
	}

	private void createEclipseProject() {
		String projectName = basePackage + mcamPackageSuffix;
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundles();
		this.p = ProjectCreator.createProject(projectName, srcFolders, null,
				reqBundles, null, null, monitor, cleanDirs, false);
	}

	private void copyAndIncludeJar(String name) throws CoreException,
			IOException {
		IFolder folder = p.getFolder("lib");
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

		classpathEntries.add(JavaCore.newLibraryEntry(
				new Path(file.getLocation().toString()), // library location
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

	private Set<String> getReqBundles() {
		HashSet<String> reqBundles = new HashSet<String>();

		reqBundles.add("org.eclipse.core.runtime");
		reqBundles.add("de.jabc.cinco.meta.core.mgl.model");
		reqBundles.add("org.eclipse.graphiti.mm");
		reqBundles.add(basePackage);

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
