package de.jabc.cinco.meta.plugin.executable;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry;
import de.jabc.cinco.meta.core.utils.BuildProperties;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class ExecutableMetaPlugin implements IMetaPlugin {

	public ExecutableMetaPlugin() {
	}

	@Override
	public String execute(Map<String, Object> map) {
		boolean wasCreated = false;
		boolean executorCreated = false;	
		String projectPath = "";
			LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
			LightweightExecutionEnvironment environment = new DefaultLightweightExecutionEnvironment(context);
			for(String str :map.keySet()){
				context.put(str, map.get(str));
			}
			GraphModel graphModel = (GraphModel) context.get("graphModel");
			IProgressMonitor progressMonitor = new NullProgressMonitor();
			
			if(!ResourcesPlugin.getWorkspace().getRoot().exists(new Path("/de.jabc.cinco.plugin.executor/")))
				try {
					wasCreated = createExecutorPlugin(progressMonitor,context);
				} catch (CoreException e1) {
					
					e1.printStackTrace();
				}
			
			String projectName = graphModel.getPackage()+".executor";
			if(!ResourcesPlugin.getWorkspace().getRoot().exists(new Path("/"+projectName))){
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			List<IProject> referencedProjects = new ArrayList<>();
			Set<String> requiredBundles = new HashSet<>();
			requiredBundles.add("de.jabc.cinco.meta.core.mgl");
			requiredBundles.add("de.jabc.cinco.plugin.executor");
			List<String> exportedPackages = new ArrayList<>();
			List<String> additionalNature = new ArrayList<>();
			IProject tvProject = ProjectCreator.createProject(projectName,
					srcFolders, referencedProjects, requiredBundles,
					exportedPackages, additionalNature, progressMonitor,false);
			executorCreated = true;
			projectPath = tvProject.getLocation().makeAbsolute()
					.toPortableString();
			BundleRegistry.INSTANCE.addBundle("de.jabc.cinco.plugin.executor",false);
			BundleRegistry.INSTANCE.addBundle(projectName,true);
			File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
			BufferedWriter bufwr;
			try {
				bufwr = new BufferedWriter(new FileWriter(maniFile,true));
			
			bufwr.append("Fragment-Host: de.jabc.cinco.plugin.executor");
			bufwr.append("\n");
			bufwr.flush();
			bufwr.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				map.put("exception", e);
				return "error";
			}
			}
			
			context.put("executorProjectCreated", new Boolean(executorCreated));
			context.put("wasCreated", new Boolean(wasCreated));
			context.put("projectPath", projectPath);
			context.put("outlet",projectPath);
			context.put("graphModelName",graphModel.getName());
			context.put("packageName", graphModel.getPackage());
			context.put("executorPackageName", graphModel.getPackage()+".executor");
			context.put("srcFolder",projectPath+"/src/");
			context.put("pluginPackageName","de.jabc.cinco.plugin.executor");
			context.put("handlerPackageName", "de.jabc.cinco.plugin.executor.handlers");
			
			
			Generate_Executor_Plugin gen = new Generate_Executor_Plugin();
			String genBranch =gen.execute(environment);
			try {
				ResourcesPlugin.getWorkspace().getRoot().refreshLocal(IProject.DEPTH_INFINITE, progressMonitor);
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				map.put("exception", e);
				return "error";
			}
			
			return genBranch;
		
		
	}

	private boolean createExecutorPlugin(IProgressMonitor progressMonitor,LightweightExecutionContext context) throws CoreException {
		if(!ResourcesPlugin.getWorkspace().getRoot().exists(new Path("/de.jabc.cinco.plugin.executor/"))){
			String projectName = "de.jabc.cinco.plugin.executor";
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			List<IProject> referencedProjects = new ArrayList<>();
			Set<String> requiredBundles = new HashSet<>();
			requiredBundles.add("de.jabc.cinco.meta.core.mgl");
			requiredBundles.add("org.eclipse.ui");
			requiredBundles.add("org.eclipse.core.runtime");
			requiredBundles.add("org.eclipse.core.resources");
			requiredBundles.add("org.eclipse.ui.navigator");
			requiredBundles.add("org.eclipse.emf.common");
			requiredBundles.add("org.eclipse.emf.ecore");
			requiredBundles.add("org.eclipse.graphiti.ui");
			requiredBundles.add("org.eclipse.ui.workbench");
			List<String> exportedPackages = new ArrayList<>();
			
			List<String> additionalNature = new ArrayList<>();
			IProject tvProject = ProjectCreator.createProject(projectName,
					srcFolders, referencedProjects, requiredBundles,
					exportedPackages, additionalNature, progressMonitor,false);
			try{
				File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
				BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
				bufwr.append("Bundle-Activator: " +projectName+".Activator\n");
				bufwr.append("Bundle-ActivationPolicy: lazy\n");
				bufwr.append("Export-Package: de.jabc.cinco.plugin.executor,\n");
				bufwr.append(" de.jabc.cinco.plugin.executor.handlers\n");
				
				bufwr.flush();
				bufwr.close();
				String projectPath = tvProject.getLocation().makeAbsolute()
						.toPortableString();
				
				Bundle bundle = Platform.getBundle("de.jabc.cinco.meta.plugin.executable");
				
				
				File iconsPath = new File(projectPath+"/icons/");
				iconsPath.mkdirs();
				File xf = new File(projectPath+"/icons/play.png");
		
				xf.createNewFile();
				FileOutputStream out = new FileOutputStream(xf);
				
				InputStream in = FileLocator.openStream(bundle, new Path("icons/play.png"), true);
				
				int i= in.read();
				while(i!=-1){
					
					out.write(i);
					i = in.read();
				}
				out.flush();
				out.close();
				File schemaDirectory = new File(projectPath+"/schema/");
				schemaDirectory.mkdir();
				System.out.println(schemaDirectory.isDirectory());
				context.put("schemaDirectory",schemaDirectory);
				context.put("executorPath", projectPath);
				
				IFile bpf = (IFile) tvProject.findMember("build.properties");
				BuildProperties buildProperties = BuildProperties.loadBuildProperties(bpf);
				buildProperties.appendBinIncludes("plugin.xml");
				buildProperties.appendBinIncludes("icons/");
				buildProperties.appendBinIncludes("schema/");
				buildProperties.store(bpf, progressMonitor);
			
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				
				return false;
			}
				
				return true;
			}
		return false;
	}

}
