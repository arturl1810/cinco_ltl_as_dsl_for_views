package de.jabc.cinco.meta.plugin.ocl;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;

import de.jabc.cinco.meta.plugin.ocl.templates.OCLValidateActionTemplate;
import de.jabc.cinco.meta.plugin.ocl.templates.PluginXmlTemplate;
import de.jabc.cinco.meta.plugin.ocl.templates.ServiceLoaderTemplate;
import de.jabc.cinco.meta.plugin.ocl.templates.StartUpActionTemplate;
import de.jabc.cinco.meta.plugin.ocl.templates.ValidateActionTemplate;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;


public class OCLPluginProjectCreater {
	public static void createPlugin(GraphModel graphModel) throws IOException, CoreException {
		String pluginPath = ".plugin.ocl";
		List<String> exportedPackages = new ArrayList<>();
		List<String> additionalNature = new ArrayList<>();
		String projectName = graphModel.getPackage() + pluginPath;
		List<IProject> referencedProjects = new ArrayList<>();
		
		//Create SRC-Folders
		List<String> srcFolders = new ArrayList<>();
		srcFolders.add("src");
		
		//Determines the symbolic name
		IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(new Path(graphModel.eResource().getURI().toPlatformString(true)));
		String symbolicName;
		if (res != null)
			symbolicName = ProjectCreator.getProjectSymbolicName(res.getProject());
		else symbolicName = graphModel.getPackage();
		
		//Sets required Bundles for the generated PlugIn-Project
		Set<String> requiredBundles = new HashSet<>();
		requiredBundles.add(symbolicName);
		requiredBundles.add("org.eclipse.core.runtime");
		requiredBundles.add("org.eclipse.core.resources");
		requiredBundles.add("org.eclipse.graphiti.ui");
		requiredBundles.add("org.eclipse.core.expressions");
		requiredBundles.add("org.eclipse.emf.ecore");
		requiredBundles.add("org.eclipse.graphiti");
		requiredBundles.add("de.jabc.cinco.meta.libraries");
		requiredBundles.add("de.jabc.cinco.meta.core");
		requiredBundles.add("org.eclipse.ui.workbench");
		requiredBundles.add("org.eclipse.emf.edit.ui");
		requiredBundles.add("org.eclipse.ocl");
		requiredBundles.add("org.eclipse.emf");
		requiredBundles.add("org.eclipse.ocl.ecore");
		requiredBundles.add("org.eclipse.emf.transaction");
		requiredBundles.add("org.eclipse.emf.edit");
		requiredBundles.add("org.eclipse.ui.ide");
		requiredBundles.add("org.eclipse.ui.views.properties.tabbed");
		requiredBundles.add("org.eclipse.gef");
		requiredBundles.add("org.eclipse.core.commands");
		
		//Overwrites the old generated code
		if(new Path("/"+projectName).toFile().exists())
			new Path("/"+projectName).toFile().delete();
		
		if(new Path("/"+projectName+"/ui").toFile().exists())
			new Path("/"+projectName+"/ui").toFile().delete();
		
		IProgressMonitor progressMonitor = new NullProgressMonitor();
		
		//Creates the Project
		IProject tvProject = ProjectCreator.createProject(projectName,
				srcFolders, referencedProjects, requiredBundles,
				exportedPackages, additionalNature, progressMonitor,false,new PluginXmlTemplate().create(projectName).toString());
		String projectPath = tvProject.getLocation().makeAbsolute()
				.toPortableString();
		
		//Generate Classes
		//Handler
		ProjectCreator.createFile("StartUpAction.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
				new StartUpActionTemplate().create(projectName).toString(),
				progressMonitor);
		ProjectCreator.createFile("ValidateAction.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
				new ValidateActionTemplate().create(projectName).toString(),
				progressMonitor);
		ProjectCreator.createFile("OCLValidateAction.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
				new OCLValidateActionTemplate().create(projectName).toString(),
				progressMonitor);
		ProjectCreator.createFile("ServiceLoader.java", tvProject.getFolder("src/"+projectName.replace(".","/")),
				new ServiceLoaderTemplate().create(projectName).toString(),
				progressMonitor);
		
		
		//Write the MANIFEST.MF
		File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
		BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
		
		bufwr.append("Bundle-ActivationPolicy: lazy\n");
		bufwr.flush();
		bufwr.close();
		
		
		tvProject.refreshLocal(IResource.DEPTH_INFINITE, null);
	}
}
