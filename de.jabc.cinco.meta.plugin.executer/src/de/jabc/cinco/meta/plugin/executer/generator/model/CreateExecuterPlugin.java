package de.jabc.cinco.meta.plugin.executer.generator.model;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import de.jabc.cinco.meta.plugin.executer.collector.GraphmodelCollector;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel;
import de.jabc.cinco.meta.plugin.executer.generator.tracer.TracerProjectGenerator;
import de.jabc.cinco.meta.plugin.executer.service.ProjectCreator;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;
import mgl.GraphModel;

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

	
	public static String toFirstUpper(String s) {
		return Character.toUpperCase(s.charAt(0)) + s.substring(1);
	}
	
	public static String toFirstLower(String s) {
		return Character.toLowerCase(s.charAt(0)) + s.substring(1);
	}
	
	
}

