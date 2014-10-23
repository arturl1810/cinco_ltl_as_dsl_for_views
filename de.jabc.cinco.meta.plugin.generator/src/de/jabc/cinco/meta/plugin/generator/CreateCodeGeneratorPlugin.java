package de.jabc.cinco.meta.plugin.generator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import mgl.GraphModel;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import com.google.common.collect.Maps;

import de.jabc.cinco.meta.core.mgl.transformation.helper.AbstractService;
import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreateCodeGeneratorPlugin extends AbstractService {


	public CreateCodeGeneratorPlugin() {
	}

	@Override
	public String execute(LightweightExecutionEnvironment environment)
			throws ServiceException {
		IProject proj = this.createCodeGeneratorEclipseProject(environment);
		if (proj != null) {
			String s = new Create_Generator_Plugin().execute(environment);
			if (s.equals("default")) {
				try {
					proj.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor());
					return "default";
				} catch (CoreException e) {
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
	
	public IProject createCodeGeneratorEclipseProject(
			LightweightExecutionEnvironment environment) {
		LightweightExecutionContext context = environment.getLocalContext().getGlobalContext();
		try {
			GraphModel graphModel = (GraphModel) context.get("graphModel");
			String implementingClassName = "";
			String bundleName = "";
			String outlet = "";
			for(mgl.Annotation anno: graphModel.getAnnotations()){
				if(anno.getName().equals("generatable")){
					if (anno.getValue().size() == 3) {
						bundleName = anno.getValue().get(0);
						implementingClassName = anno.getValue().get(1);
						outlet = anno.getValue().get(2);
						break;
					} else if (anno.getValue().size() == 2) {
						implementingClassName = anno.getValue().get(0);
						outlet = anno.getValue().get(1);
					}
				}
			}
			context.put("implementingClassName",implementingClassName);
			context.put("outlet",outlet);
			String packageName = implementingClassName.substring(0, implementingClassName.lastIndexOf('.'));
			List<String> exportedPackages = new ArrayList<>();
			List<String> additionalNature = new ArrayList<>();
			String projectName = graphModel.getPackage() + ".codegen";
			List<IProject> referencedProjects = new ArrayList<>();
			List<String> srcFolders = new ArrayList<>();
			srcFolders.add("src");
			Set<String> requiredBundles = new HashSet<>();
			
			IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(new Path(graphModel.eResource().getURI().toPlatformString(true)));
			String symbolicName;
			if (res != null)
				symbolicName = ProjectCreator.getProjectSymbolicName(res.getProject());
			else symbolicName = graphModel.getPackage();
			
			if (bundleName.isEmpty()) {
				bundleName = res.getProject().getName();
			}
			
			requiredBundles.add(symbolicName);
			requiredBundles.add("org.eclipse.ui");
			requiredBundles.add("org.eclipse.core.runtime");
			requiredBundles.add("org.eclipse.core.resources");
			requiredBundles.add("org.eclipse.ui.navigator");
			requiredBundles.add("org.eclipse.emf.common");
			requiredBundles.add("org.eclipse.emf.ecore");
			requiredBundles.add("org.eclipse.graphiti.ui");
			requiredBundles.add("org.eclipse.ui.workbench");
			requiredBundles.add("de.jabc.cinco.meta.core.mgl.model");
			
			exportPackage(bundleName,packageName);
//			requiredBundles.add(bundleName);
			if(new Path("/"+projectName).toFile().exists())
				new Path("/"+projectName).toFile().delete();
			IProgressMonitor progressMonitor = new NullProgressMonitor();
			IProject tvProject = ProjectCreator.createProject(projectName,
					srcFolders, referencedProjects, requiredBundles,
					exportedPackages, additionalNature, progressMonitor,false);
			String projectPath = tvProject.getLocation().makeAbsolute()
					.toPortableString();
			
			context.put("projectPath", projectPath);
			
			File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile();
			BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile,true));
			bufwr.append("Bundle-Activator: " +projectName+".Activator\n");
			bufwr.append("Bundle-ActivationPolicy: lazy\n");
			bufwr.flush();
			bufwr.close();
			
			
			Bundle bundle = Platform.getBundle("de.jabc.cinco.meta.plugin.generator");
			
			
			File iconsPath = new File(projectPath+"/icons/");
			iconsPath.mkdirs();
			File xf = new File(projectPath+"/icons/g.gif");

			xf.createNewFile();
			FileOutputStream out = new FileOutputStream(xf);
			
			InputStream in = FileLocator.openStream(bundle, new Path("icons/g.gif"), true);
			
			int i= in.read();
			while(i!=-1){
				
				out.write(i);
				i = in.read();
			}
			out.flush();
			out.close();
			
			
			return tvProject;
		} catch (Exception e) {
			context.put("exception", e);
			return null;
		} finally {
		}

	}

	private void exportPackage(String bundleName, String packageName) {
		IProject pr = ResourcesPlugin.getWorkspace().getRoot().getProject(bundleName);
		if(pr!=null){
			Manifest manni;
			try {
				File manniFile = pr.getFile("/META-INF/MANIFEST.MF").getLocation().makeAbsolute().toFile();
				manni = new Manifest(new FileInputStream(manniFile));
				Attributes mainAttr = manni.getMainAttributes();
				String oldValues = mainAttr.getValue("Export-Package");
				if(!oldValues.contains(packageName)){
					mainAttr.putValue("Export-Package", oldValues.concat(",").concat(packageName));
					manni.write(new FileOutputStream(manniFile));
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			
		}
	}

}
