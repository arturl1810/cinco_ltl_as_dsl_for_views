package de.jabc.cinco.meta.plugin.treeviewer;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import de.jabc.cinco.meta.core.mgl.transformation.helper.AbstractService;
import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class GenerateTreeView extends AbstractService {
	public IProject createTreeViewEclipseProject(
			LightweightExecutionEnvironment environment) {
		LightweightExecutionContext context = environment.getLocalContext()
				.getGlobalContext();
		try {
			GraphModel graphModel = (GraphModel) context.get("graphModel");

			List<String> exportedPackages = new ArrayList<>();
			List<String> additionalNature = new ArrayList<>();
			String projectName = graphModel.getPackage() + ".treeview";
			List<IProject> referencedProjects = new ArrayList<>();
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			Set<String> requiredBundles = new HashSet<>();
			requiredBundles.add("org.eclipse.ui");
			requiredBundles.add("org.eclipse.core.runtime");
			requiredBundles.add(graphModel.getPackage());
			requiredBundles.add("org.eclipse.core.resources");
			requiredBundles.add("org.eclipse.ui.navigator");
			requiredBundles.add("org.eclipse.emf.common");
			requiredBundles.add("org.eclipse.emf.ecore");
			IProgressMonitor progressMonitor = new NullProgressMonitor();
			IProject tvProject = ProjectCreator.createProject(projectName,
					srcFolders, referencedProjects, requiredBundles,
					exportedPackages, additionalNature, progressMonitor, false);
			context.put("projectPath", tvProject.getLocation().makeAbsolute()
					.toPortableString());
			
			File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
			BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
			bufwr.append("Bundle-Activator: " +projectName+".Activator\n");
			bufwr.append("Bundle-ActivationPolicy: lazy\n");
			bufwr.flush();
			bufwr.close();
			
			return tvProject;
		} catch (Exception e) {
			context.put("exception", e);
			return null;
		}

	}

	@Override
	public String execute(LightweightExecutionEnvironment environment)
			throws ServiceException {
		IProject proj = this.createTreeViewEclipseProject(environment);
		if (proj != null) {
			String s = new CreateTreeView().execute(environment);
			if (s.equals("default")) {
				try {
					proj.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor());
					return "default";
				} catch (CoreException e) {
					// TODO Auto-generated catch block
					environment.getLocalContext().getGlobalContext()
							.put("exception", e);
					return "error";
				}

			} else {
				return "error";

			}
		} else {
			return "error";
		}
	}
}
