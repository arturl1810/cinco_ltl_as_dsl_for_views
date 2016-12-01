package de.jabc.cinco.meta.plugin.executer.generator.model;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.WorkspaceUtil;
import de.jabc.cinco.meta.plugin.executer.collector.GraphmodelCollector;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel;
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TracerProjectGenerator;
import de.jabc.cinco.meta.plugin.executer.service.ProjectCreator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;
import mgl.GraphModel;
import style.Styles;

public class CreateExecuterPlugin {
	public static final String EXECUTER = "execsem";
	
	public String basePath;
	
	public String execute(LightweightExecutionEnvironment env) throws IOException, URISyntaxException {
		LightweightExecutionContext context = env.getLocalContext().getGlobalContext();
		GraphModel graphModel = (GraphModel) context.get("graphModel");
		IProject project = de.jabc.cinco.meta.core.utils.projects.ProjectCreator.getProject(graphModel.eResource());
		if(project==null){
			throw new IllegalStateException("Project cannot be found");
		}
		Styles styles = CincoUtils.getStyles(graphModel);
 
		String graphModelName = graphModel.getName();
		String pluginPath = ".plugin.esdsl";
		String projectName = graphModel.getPackage() + pluginPath;
		List<String> srcFolders = new LinkedList<String>();
		srcFolders.add("src");
		
		List<IProject> referencedProjects = new LinkedList<IProject>();
		Set<String> requiredBundles = new HashSet<String>();
		requiredBundles.add(graphModel.getPackage());
		requiredBundles.add("de.jabc.cinco.meta.core.ge.style.model");
		
		List<String> exportedPackages = new LinkedList<String>();
		List<String> additionalNatures = new LinkedList<String>();
		List<String> cleanDirs = new LinkedList<String>();
		cleanDirs.add("model");
		cleanDirs.add("scr");
		String pluginXML = "";
		
		IProgressMonitor progressMonitor = new NullProgressMonitor();

		//Search for Graphmodel Annotation "executer"
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals(EXECUTER)){
				if(anno.getValue().size() != 0){
					return null;
				}
				System.out.println("Executer MGL creation running");
				
				GraphmodelCollector gc = new GraphmodelCollector();
				ExecutableGraphmodel exg = gc.transfrom(graphModel);
				
				IProject esdslProject = ProjectCreator.createProject(
							projectName,
							srcFolders,
							referencedProjects,
							requiredBundles,
							exportedPackages,
							additionalNatures,
							progressMonitor,
							cleanDirs,
							false, 
							pluginXML
						);
				
				
				
				//model
				new MGLGenerator(exg).generate("model/", esdslProject);
				new StyleGeneratorTemplate(exg,project).generate("model/", esdslProject);
				new CPDGeneratorTemplate(exg).generate("model/", esdslProject);
				
				// /src
				// /src/ .hooks
				
				/**
				 * Tracer project creation
				 */
				new TracerProjectGenerator().create(exg);
				
				
				System.out.println("Executer MGL creation finished");
				return "default";
			}
		}
		
			
		return null;
	}

	
	
	private Resource findImportModels(mgl.Import import1,GraphModel masterModel)
	{
		String path = import1.getImportURI();
		URI uri = URI.createURI(path, true);
		try {
			Resource res = null;
			if (uri.isPlatformResource()) {
				res = new ResourceSetImpl().getResource(uri, true);
			}
			else {
				IProject p = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(masterModel.eResource().getURI().toPlatformString(true))).getProject();
				IFile file = p.getFile(path);
				if (file.exists()) {
					URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
					res = new ResourceSetImpl().getResource(fileURI, true);
				}
				else {
					return null;
				}
			}
			
			return res;
			
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static String toFirstUpper(String s) {
		return Character.toUpperCase(s.charAt(0)) + s.substring(1);
	}
	
	public static String toFirstLower(String s) {
		return Character.toLowerCase(s.charAt(0)) + s.substring(1);
	}
	
	
}

