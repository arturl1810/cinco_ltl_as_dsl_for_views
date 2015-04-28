package de.jabc.cinco.meta.plugin.papyrus;

import java.io.File;
import java.io.IOException;

import mgl.GraphModel;

import org.apache.commons.io.FileUtils;

import de.jabc.cinco.meta.plugin.papyrus.model.TemplateContainer;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorCSSTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorConstraintTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorModelTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import de.jabc.cinco.meta.plugin.papyrus.utils.ModelParser;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreatePapyrusPlugin {
	public static final String PAPYRUS = "papyrus";

	public String execute(LightweightExecutionEnvironment env) throws IOException {
		LightweightExecutionContext context = env.getLocalContext().getGlobalContext();
		GraphModel graphModel = (GraphModel) context.get("graphModel");
				
		String basePath = "~/PapyrusGen/";
		//Search for Graphmodel Annotation "papyrus"
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals(PAPYRUS)){
				System.out.println("Papyrus editor creation running");
				
				TemplateContainer templateContainer = new TemplateContainer();
				templateContainer.setEdges(ModelParser.getStyledEdges(graphModel));
				templateContainer.setNodes(ModelParser.getStyledNodes(graphModel));
				templateContainer.setGraphModel(graphModel);
				templateContainer.setGroupedNodes(ModelParser.getGroupedNodes(graphModel));
				templateContainer.setValidConnections(ModelParser.getValidConnections(graphModel));

				//createFile(new EditorControllerTemplate(), basePath + "cincoController.java", templateContainer);
				createFile(new EditorModelTemplate(), basePath + "papyrus.model.java", templateContainer);
				createFile(new EditorConstraintTemplate(), basePath + "papyrus.constraint.js", templateContainer);
				createFile(new EditorCSSTemplate(), basePath + "papyrus.nodes.css", templateContainer);
				
				
				
				return "default";
			}
		}
			
		return null;
	}
	
	
	private void createFile(Templateable template,String path,TemplateContainer tc) throws IOException
	{
		//(use relative path for Unix systems)
		File f = new File(path);
		//(works for both Windows and Linux)
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(tc.getGraphModel(), tc.getNodes(), tc.getEdges(), tc.getGroupedNodes(), tc.getValidConnections()).toString());
	}
	
}

