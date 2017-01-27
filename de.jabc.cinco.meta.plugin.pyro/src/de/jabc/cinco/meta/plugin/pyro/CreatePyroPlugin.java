package de.jabc.cinco.meta.plugin.pyro;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge;
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement;
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode;
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer;
import de.jabc.cinco.meta.plugin.pyro.templates.AnnotationElementTemplateable;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorCSSTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorCommunicatorTemplyte;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorConstraintTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable;
import de.jabc.cinco.meta.plugin.pyro.templates.SVGModelTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable;
import de.jabc.cinco.meta.plugin.pyro.templates.deployment.CincoDBController;
import de.jabc.cinco.meta.plugin.pyro.templates.message.AttributeMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.CreateMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.CustomMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.EditMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.MoveMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.RemoveMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.ResizeMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.RotateMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.message.SettingsMessageParser;
import de.jabc.cinco.meta.plugin.pyro.templates.parser.GraphModelParser;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.canvas.ModelingCanvas;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.menu.Menu;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph.NewGraphDialog;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph.NewGraphDialogProperties;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph.RemoveGraphDialog;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.pages.PyroTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.services.AppModule;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph.ModelingCanvasProperties;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CContainer;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CContainerImpl;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CEdge;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CEdgeImpl;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CGraphModel;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CGraphModelImpl;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CNode;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.CNodeImpl;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.GraphWrapper;
import de.jabc.cinco.meta.plugin.pyro.templates.transformation.GraphWrapperImpl;
import de.jabc.cinco.meta.plugin.pyro.utils.EdgeParser;
import de.jabc.cinco.meta.plugin.pyro.utils.FileHandler;
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser;
import de.jabc.cinco.meta.plugin.pyro.utils.NodeParser;
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension;
import mgl.Annotation;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Type;
import style.Styles;

public class CreatePyroPlugin {
	
	private static WorkspaceExtension workspace = new WorkspaceExtension();
	
	public static final String PYRO = "pyro";
	public static final String PRIME = "primeviewer";
	public static final String PRIME_LABEL = "pvLabel";
	IFolder dywaAppfolder;
	
	public void execute(Set<GraphModel> graphModels,IProject project) throws IOException, URISyntaxException {
		dywaAppfolder = workspace.createFolder(project,"dywa-app");
		String jsPath = "js/pyro/";
		String cssPath = "css/pyro/";
		String businessPath = "/app-business/target/generated-sources/de/ls5/cinco/pyro/";
		String presentationPath = "/app-presentation/target/generated-sources/";
		String componentsPath = "de/ls5/cinco/pyro/";
		String resourcesPath = "resources/de/ls5/cinco/pyro/";
		String webappPath = "webapp/";
		String preconfigPath = "/app-preconfig/target/generated-sources/de/ls5/cinco/pyro/";
		//Search for Graphmodel Annotation "pyro"
		
		ArrayList<EPackage> ecores = new ArrayList<EPackage>();
		for(GraphModel gModel:graphModels)
		{
			for(mgl.Import import1 : gModel.getImports()) {
				
				Resource r = (Resource) findImportModels(import1,gModel);
				if(r != null) {
					for(EObject eObject:r.getContents() ){
						if(eObject instanceof EPackage) {
							EPackage ePackage = (EPackage) eObject;
							if(!ePackage.getName().equals(gModel.getName()) && !gModel.getNsURI().equals(ePackage.getNsURI())){
								ecores.add((EPackage) eObject);								
							}
						}								
					}
				}
			}
		}
				
				
		TemplateContainer templateContainer = new TemplateContainer();
				
		templateContainer.setEcores(ecores);
		templateContainer.setGraphModels(graphModels);
		//Testapp-Business
		createFile(new CincoDBController(), preconfigPath+ "deployment/CincoDBControllerImpl.java", templateContainer);

				
		//Testapp-Presentation
		createFile(new ModelingCanvas(), presentationPath+componentsPath+ "components/canvas/ModelingCanvas.java", templateContainer);
		createFile(new Menu(), presentationPath+componentsPath+ "components/menubar/Menu.java", templateContainer);
		createFile(new NewGraphDialog(), presentationPath+componentsPath+ "components/modals/graph/NewGraphDialog.java", templateContainer);
		createFile(new NewGraphDialogProperties(), presentationPath+resourcesPath+ "components/modals/graph/NewGraphDialog.properties", templateContainer);
		createFile(new RemoveGraphDialog(), presentationPath+componentsPath+ "components/modals/graph/RemoveGraphDialog.java", templateContainer);
		createFile(new AppModule(), presentationPath+componentsPath+ "services/AppModule.java", templateContainer);
		createFile(new ModelingCanvasProperties(), presentationPath+resourcesPath+ "components/canvas/ModelingCanvas.properties", templateContainer);
		createFile(new de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph.ModelingCanvas(), presentationPath+resourcesPath+ "components/canvas/ModelingCanvas.tml", templateContainer);
		createFile(new PyroTemplate(), presentationPath+componentsPath+ "pages/Pyro.java", templateContainer);
				
		//Clear Folders
		deleteFolder(businessPath+"parser");
		deleteFolder(businessPath+ "message");
		deleteFolder(businessPath+"transformation/api");
				
		// For all imported or referenced GraphModels
		for(GraphModel iteratorModel:graphModels) {
			Styles styles = CincoUtils.getStyles(iteratorModel,project);

			String graphModelPath = toFirstLower(iteratorModel.getName()) + "/";
					
			templateContainer.setEdges(EdgeParser.getStyledEdges(iteratorModel,styles));
			templateContainer.setEnums(new LinkedList<Type>(iteratorModel.getTypes()));
			List<GraphicalModelElement> graphicalModelElements = new LinkedList<GraphicalModelElement>();
			graphicalModelElements.addAll(iteratorModel.getNodes());

			templateContainer.setNodes(NodeParser.getStyledNodes(iteratorModel,graphicalModelElements,styles));
			templateContainer.setGraphModel(iteratorModel);
			templateContainer.setGroupedNodes(ModelParser.getGroupedNodes(graphicalModelElements));
			templateContainer.setValidConnections(ModelParser.getValidConnections(iteratorModel));
			templateContainer.setEmbeddingConstraints(ModelParser.getValidEmbeddings(iteratorModel));
					
			//Copy Images
			FileHandler.copyImages(iteratorModel, presentationPath +webappPath,project);
					
			createFile(new EditorCommunicatorTemplyte(), presentationPath +webappPath+ jsPath +graphModelPath+"pyro.communicator.js", templateContainer);
			//createFile(new EditorModelTemplate(), presentationPath +webappPath+ jsPath +graphModelPath+"pyro.model.js", templateContainer);
			createFile(new SVGModelTemplate(), presentationPath +webappPath+ jsPath +graphModelPath+"pyro.model.js", templateContainer);
			createFile(new EditorConstraintTemplate(), presentationPath +webappPath+ jsPath +graphModelPath+ "pyro.constraints.js", templateContainer);
			createFile(new EditorCSSTemplate(), presentationPath +webappPath+ cssPath +graphModelPath+ "pyro.nodes.css", templateContainer);
					
			//CustomActions
			for(Annotation annotation:iteratorModel.getAnnotations())
			{
				if(annotation.getName().equals("contextMenuAction"))
				{
					createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.GraphCustomAction(), null,annotation, businessPath+"custom/action/"+graphModelPath+ ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
				}
			}
			for(StyledNode styledNode : templateContainer.getNodes())
			{
				for(Annotation annotation:styledNode.getModelElement().getAnnotations())
				{
					if(annotation.getName().equals("contextMenuAction"))
					{
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.CustomAction(), styledNode,annotation, businessPath+"custom/action/"+graphModelPath+ ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
					}
				}
			}
			for(StyledEdge styledEdge : templateContainer.getEdges())
			{
				for(Annotation annotation:styledEdge.getModelElement().getAnnotations())
				{
					if(annotation.getName().equals("contextMenuAction"))
					{
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.CustomAction(), styledEdge,annotation, businessPath+"custom/action/"+graphModelPath+  ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
					}
				}
			}
					
			//Custom Hooks
			for(Annotation annotation:iteratorModel.getAnnotations())
			{
				if(annotation.getName().equals("postCreate"))
				{
					createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.hook.GraphCustomHook(), null,annotation, businessPath+"custom/hook/"+graphModelPath+ ModelParser.getCustomHookName(annotation)+"CustomHook.java", templateContainer);							
				}
			}
			for(StyledNode styledNode : templateContainer.getNodes())
			{
				for(Annotation annotation:styledNode.getModelElement().getAnnotations())
				{
					if(annotation.getName().equals("postCreate"))
					{
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.hook.CustomHook(), styledNode,annotation, businessPath+"custom/hook/"+graphModelPath+ ModelParser.getCustomHookName(annotation)+"CustomHook.java", templateContainer);							
					}
				}
			}
			for(StyledEdge styledEdge : templateContainer.getEdges())
			{
				for(Annotation annotation:styledEdge.getModelElement().getAnnotations())
				{
					if(annotation.getName().equals("postCreate"))
					{
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.hook.CustomHook(), styledEdge,annotation,businessPath+"custom/hook/"+graphModelPath+  ModelParser.getCustomHookName(annotation)+"CustomHook.java", templateContainer);							
					}
				}
			}
					
			//Parser
			//deleteFolder(basePath+businessPath+"parser/"+graphModelPath);
			createFile(new GraphModelParser(),null, businessPath+"parser/"+graphModelPath+ iteratorModel.getName()+"Parser.java", templateContainer);
			for(StyledNode styledNode : templateContainer.getNodes())
			{
				createFile(new de.jabc.cinco.meta.plugin.pyro.templates.parser.NodeParser(), styledNode, businessPath+"parser/"+graphModelPath+ styledNode.getModelElement().getName()+"Parser.java", templateContainer);
			}
			for(StyledEdge styledEdge : templateContainer.getEdges())
			{
				createFile(new de.jabc.cinco.meta.plugin.pyro.templates.parser.EdgeParser(), styledEdge, businessPath+"parser/"+graphModelPath+ styledEdge.getModelElement().getName()+"Parser.java", templateContainer);
			}
					
			//Message
			createFile(new CreateMessageParser(), businessPath+ "message/"+graphModelPath+"CreateMessageParser.java", templateContainer);
			createFile(new RemoveMessageParser(), businessPath+ "message/"+graphModelPath+"RemoveMessageParser.java", templateContainer);
			createFile(new MoveMessageParser(), businessPath+ "message/"+graphModelPath+"MoveMessageParser.java", templateContainer);
			createFile(new EditMessageParser(), businessPath+ "message/"+graphModelPath+"EditMessageParser.java", templateContainer);
			createFile(new ResizeMessageParser(), businessPath+ "message/"+graphModelPath+"ResizeMessageParser.java", templateContainer);
			createFile(new RotateMessageParser(), businessPath+ "message/"+graphModelPath+"RotateMessageParser.java", templateContainer);
			createFile(new AttributeMessageParser(), businessPath+ "message/"+graphModelPath+"AttributeMessageParser.java", templateContainer);
			createFile(new CustomMessageParser(), businessPath+ "message/"+graphModelPath+"CustomFeatureParser.java", templateContainer);
			createFile(new SettingsMessageParser(), businessPath+ "message/"+graphModelPath+"SettingsMessageParser.java", templateContainer);
					
			//Transformation
			createFile(new GraphWrapper(), businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"Wrapper.java", templateContainer);
			createFile(new GraphWrapperImpl(), businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"WrapperImpl.java", templateContainer);
					
			createFile(new CGraphModel(), businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+".java", templateContainer);
			createFile(new CGraphModelImpl(), businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"Impl.java", templateContainer);
					
			for(StyledNode styledNode : templateContainer.getNodes())
			{
				if(styledNode.getModelElement() instanceof mgl.NodeContainer)
				{
					createFile(new CContainer(), styledNode, businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+".java", templateContainer);
					createFile(new CContainerImpl(), styledNode, businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+"Impl.java", templateContainer);						
				}
				else
				{
					createFile(new CNode(), styledNode, businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+".java", templateContainer);
					createFile(new CNodeImpl(), styledNode, businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+"Impl.java", templateContainer);
				}
			}
			for(StyledEdge styledEdge : templateContainer.getEdges())
			{
				createFile(new CEdge(), styledEdge, businessPath+"transformation/api/"+graphModelPath+"C"+ styledEdge.getModelElement().getName()+".java", templateContainer);
				createFile(new CEdgeImpl(), styledEdge, businessPath+"transformation/api/"+graphModelPath+"C"+ styledEdge.getModelElement().getName()+"Impl.java", templateContainer);
			}					
			FileHandler.copyResources("de.jabc.cinco.meta.plugin.pyro",workspace.getFolder(dywaAppfolder).getParent().getRawLocation().toOSString());
		}
								
	}
	
	private void createFile(Templateable template,String path,TemplateContainer tc) throws IOException
	{
		workspace.createFile(dywaAppfolder, path, template.create(tc).toString(),true);
	}
	
	private void createFile(ElementTemplateable template,StyledModelElement sme,String path,TemplateContainer tc) throws IOException
	{
		workspace.createFile(dywaAppfolder, path, template.create(sme,tc).toString(),true);
	}
	private void createFile(AnnotationElementTemplateable template,StyledModelElement sme,mgl.Annotation anno,String path,TemplateContainer tc) throws IOException
	{
		workspace.createFile(dywaAppfolder, path, template.create(anno,sme,tc).toString(),true);
	}
	
	private void deleteFolder(String path) throws IOException {
		File folder = new File(dywaAppfolder.getFullPath().toOSString()+path);
		FileUtils.deleteDirectory(folder);
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

