package de.jabc.cinco.meta.plugin.papyrus;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Type;

import org.apache.commons.io.FileUtils;

import style.Styles;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.papyrus.model.TemplateContainer;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorCSSTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorConstraintTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.EditorModelTemplate;
import de.jabc.cinco.meta.plugin.papyrus.templates.Templateable;
import de.jabc.cinco.meta.plugin.papyrus.utils.EdgeParser;
import de.jabc.cinco.meta.plugin.papyrus.utils.FileHandler;
import de.jabc.cinco.meta.plugin.papyrus.utils.ModelParser;
import de.jabc.cinco.meta.plugin.papyrus.utils.NodeParser;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreatePapyrusPlugin {
	public static final String PAPYRUS = "papyrus";
	
	public String execute(LightweightExecutionEnvironment env) throws IOException {
		LightweightExecutionContext context = env.getLocalContext().getGlobalContext();
		GraphModel graphModel = (GraphModel) context.get("graphModel");
		Styles styles = CincoUtils.getStyles(graphModel);
		String basePath = "CincoProductsFTWGen/papyrus/";
		String jsPath = "/papyrus/js/papyrus/";
		String cssPath = "/papyrus/css/papyrus/";
		//Search for Graphmodel Annotation "papyrus"
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals(PAPYRUS)){
				System.out.println("Papyrus editor creation running");
				if(anno.getValue().size() != 1){
					return null;
				}
				basePath = anno.getValue().get(0);
				FileHandler.copyResources("de.jabc.cinco.meta.plugin.papyrus",basePath);
				
				TemplateContainer templateContainer = new TemplateContainer();
				templateContainer.setEdges(EdgeParser.getStyledEdges(graphModel,styles));
				templateContainer.setEnums(new ArrayList<Type>(graphModel.getTypes()));
				ArrayList<GraphicalModelElement> graphicalModelElements = new ArrayList<GraphicalModelElement>();
				graphicalModelElements.addAll(graphModel.getNodes());
				graphicalModelElements.addAll(graphModel.getNodeContainers());
				templateContainer.setNodes(NodeParser.getStyledNodes(graphModel,graphicalModelElements,styles));
				templateContainer.setGraphModel(graphModel);
				templateContainer.setGroupedNodes(ModelParser.getGroupedNodes(graphicalModelElements));
				templateContainer.setValidConnections(ModelParser.getValidConnections(graphModel));
				templateContainer.setEmbeddingConstraints(ModelParser.getValidEmbeddings(graphModel));

				//createFile(new EditorControllerTemplate(), basePath + "cincoController.java", templateContainer);
				createFile(new EditorModelTemplate(), basePath + jsPath +"papyrus.model.js", templateContainer);
				createFile(new EditorConstraintTemplate(), basePath + jsPath + "papyrus.constraints.js", templateContainer);
				createFile(new EditorCSSTemplate(), basePath + cssPath + "papyrus.nodes.css", templateContainer);
				
				
				
				return "default";
			}
		}
			
		return null;
	}
	
	
	private void createFile(Templateable template,String path,TemplateContainer tc) throws IOException
	{
		File f = new File(path);
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(tc.getGraphModel(), tc.getNodes(), tc.getEdges(), tc.getGroupedNodes(), tc.getValidConnections(),tc.getEmbeddingConstraints(),tc.getEnums()).toString());
	}
	
}

