package de.jabc.cinco.meta.plugin.mcam;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class MetaPluginMcam implements IMetaPlugin {

	private GraphModel gModel;

	public MetaPluginMcam() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public String execute(Map<String, Object> map) {

		gModel = (GraphModel) map.get("graphModel");

		String projectName = gModel.getPackage().concat(".mcam");
		System.out.println("Project Name: " + projectName);

		String path = ResourcesPlugin.getWorkspace().getRoot().getLocation()
				.append(projectName).toOSString();
		System.out.println("Path: " + path);

		System.out.println("Creating Eclipse-Project...");
		NullProgressMonitor monitor = new NullProgressMonitor();
		List<String> srcFolders = getSrcFolders();
		List<String> cleanDirs = getCleanDirectory();
		Set<String> reqBundles = getReqBundles();
		IProject p = ProjectCreator.createProject(projectName, srcFolders,
				null, reqBundles, null, null, monitor, cleanDirs, false);

		System.out.println("Generating Model-CaM Implementation...");
		LightweightExecutionContext context = new DefaultLightweightExecutionContext(
				null);
		context.put("graphModel", gModel);
		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(
				context);

		try {
			Main mainGraph = new Main();
			String result = mainGraph.execute(env);
			if (result.equals("error")) {
				Exception e = (Exception) context.get("exception");
				throw new ExecutionException(e.getMessage());

			}
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			
		} catch (CoreException e) {
			e.printStackTrace();
			return "error";
		} catch (ExecutionException e1) {
			e1.printStackTrace();
			return "error";
		}

		return "default";
	}

	private Set<String> getReqBundles() {
		HashSet<String> reqBundles = new HashSet<String>();
		List<Bundle> bundles = new ArrayList<Bundle>();

		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.runtime"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
		bundles.add(Platform.getBundle("org.eclipse.ui.navigator"));
		bundles.add(Platform
				.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.mgl.model"));
		bundles.add(Platform
				.getBundle("de.jabc.cinco.meta.core.ge.style.model"));
		bundles.add(Platform
				.getBundle("de.jabc.cinco.meta.core.referenceregistry"));

		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));

		for (Bundle b : bundles) {
			StringBuilder s = new StringBuilder();
			s.append(b.getSymbolicName());
			s.append(";bundle-version=");
			s.append("\"" + b.getVersion().getMajor() + "."
					+ b.getVersion().getMinor() + "."
					+ b.getVersion().getMicro() + "\"");
			reqBundles.add(s.toString());
		}
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
		cleanDirs.add("icons");
		return cleanDirs;
	}
}
