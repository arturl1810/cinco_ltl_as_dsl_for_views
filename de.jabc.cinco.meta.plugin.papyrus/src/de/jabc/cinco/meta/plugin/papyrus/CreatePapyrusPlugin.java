package de.jabc.cinco.meta.plugin.papyrus;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.commons.io.FileUtils;

import mgl.Edge;
import mgl.GraphModel;
import mgl.Node;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorCSSTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorControllerTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorModelTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import de.jabc.cinco.meta.plugin.papyrus.utils.ModelStyler;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreatePapyrusPlugin {
	public static final String PAPYRUS = "papyrus";

	public String execute(LightweightExecutionEnvironment env) throws IOException {
		LightweightExecutionContext context = env.getLocalContext().getGlobalContext();
		GraphModel graphModel = (GraphModel) context.get("graphModel");
				
		//Search for Graphmodel Annotation "papyrus"
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals(PAPYRUS)){
				System.out.println("Papyrus editor creation running");
				
				ArrayList<StyledModelElement> styledModelElements = ModelStyler.getStyledModelElements(graphModel);
				ArrayList<StyledModelElement> edges = ModelStyler.getStyledEdges(styledModelElements);
				ArrayList<StyledModelElement> nodes = ModelStyler.getStyledNodes(styledModelElements);
				
				this.createEditorModels(graphModel,nodes,edges);
				this.createEditorCSS(graphModel,nodes,edges);
				this.createEditorController(graphModel,nodes,edges);
				return "default";
			}
		}
			
		return null;
	}
	
	

	public void createEditorModels(GraphModel graphModel,ArrayList<StyledModelElement> nodes, ArrayList<StyledModelElement> edges) throws IOException
	{
		String path = "/home/zweihoff/Projekte/Papyrus/js/papyrus/papyrus.model.test.js";
		createFile(path, new EditorModelTemplate(), graphModel, nodes, edges);
	}
	
	public void createEditorCSS(GraphModel graphModel,ArrayList<StyledModelElement> nodes, ArrayList<StyledModelElement> edges) throws IOException
	{
		String path = "/home/zweihoff/Projekte/Papyrus/css/papyrus.model.test.css";
		createFile(path, new EditorCSSTemplate(), graphModel, nodes, edges);
	}
	
	public void createEditorController(GraphModel graphModel,ArrayList<StyledModelElement> nodes, ArrayList<StyledModelElement> edges) throws IOException
	{
		String path = "/home/zweihoff/Projekte/Papyrus/js/papyrus.controller.test.js";
		createFile(path, new EditorControllerTemplate(), graphModel, nodes, edges);
	}
	
	private void createFile(String path,Templateable template,GraphModel graphModel,ArrayList<StyledModelElement> nodes, ArrayList<StyledModelElement> edges) throws IOException
	{
		//(use relative path for Unix systems)
		File f = new File(path);
		//(works for both Windows and Linux)
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(graphModel, nodes, edges).toString());
	}
	
}

