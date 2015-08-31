package de.jabc.cinco.meta.plugin.pyro;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;

import mgl.Annotation;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Type;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.Styles;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge;
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement;
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode;
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer;
import de.jabc.cinco.meta.plugin.pyro.templates.AnnotationElementTemplateable;
import de.jabc.cinco.meta.plugin.pyro.templates.DefaultTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorCSSTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorCommunicatorTemplyte;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorConstraintTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.EditorModelTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable;
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
import de.jabc.cinco.meta.plugin.pyro.templates.script.DeployPyroLinuxTemplate;
import de.jabc.cinco.meta.plugin.pyro.templates.script.DeployPyroWindowsTemplate;
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
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class CreatePyroPlugin {
	public static final String PYRO = "pyro";
	public static final String PRIME = "primeviewer";
	public static final String PRIME_LABEL = "pvLabel";
	
	public String basePath;
	
	public String execute(LightweightExecutionEnvironment env) throws IOException, URISyntaxException {
		LightweightExecutionContext context = env.getLocalContext().getGlobalContext();
		GraphModel graphModel = (GraphModel) context.get("graphModel");
		Styles styles = CincoUtils.getStyles(graphModel);
		basePath = "CincoProductsFTWGen/pyro/";
		String jsPath = "js/pyro/";
		String cssPath = "css/pyro/";
		String wildFlyPath ="~/";
		String businessPath = "/testapp-business/src/main/java/de/ls5/cinco/";
		String presentationPath = "/testapp-presentation/src/main/";
		String componentsPath = "java/de/mtf/dywa/";
		String resourcesPath = "resources/de/mtf/dywa/";
		String webappPath = "webapp/";
		String preconfigPath = "/testapp-preconfig/src/main/java/de/ls5/cinco/";
		//Search for Graphmodel Annotation "pyro"
		for(mgl.Annotation anno: graphModel.getAnnotations()){
			if(anno.getName().equals(PYRO)){
				System.out.println("Pyro editor creation running");
				if(anno.getValue().size() != 2){
					return null;
				}
				basePath = anno.getValue().get(0);
				wildFlyPath = anno.getValue().get(1);
				
				ArrayList<GraphModel> graphModels = new ArrayList<GraphModel>();
				graphModels.add(graphModel);
				
				ArrayList<EPackage> ecores = new ArrayList<EPackage>();
				
				for(mgl.Import import1 : graphModel.getImports()) {
					
						Resource r = (Resource) findImportModels(import1,graphModel);
						if(r != null) {
							for(EObject eObject:r.getContents() ){
								if(eObject instanceof EPackage) {
									EPackage ePackage = (EPackage) eObject;
									if(!ePackage.getName().equals(graphModel.getName()) && !graphModel.getNsURI().equals(ePackage.getNsURI())){
										ecores.add((EPackage) eObject);								
									}
								}								
							}
						}
				}
				
				
				TemplateContainer templateContainer = new TemplateContainer();
				
				templateContainer.setEcores(ecores);
				templateContainer.setGraphModels(graphModels);
				//Testapp-Business
				createFile(new CincoDBController(), basePath+preconfigPath+ "deployment/CincoDBControllerImpl.java", templateContainer);
				//Scripts
				createFile(new DeployPyroLinuxTemplate(),basePath+"/deployment/deployPyro.sh", basePath,wildFlyPath);
				createFile(new DeployPyroWindowsTemplate(),basePath+"/deployment/deployPyro.bat", basePath,wildFlyPath);
				
				//Testapp-Presentation
				createFile(new ModelingCanvas(), basePath+presentationPath+componentsPath+ "components/canvas/ModelingCanvas.java", templateContainer);
				createFile(new Menu(), basePath+presentationPath+componentsPath+ "components/menubar/Menu.java", templateContainer);
				createFile(new NewGraphDialog(), basePath+presentationPath+componentsPath+ "components/modals/graph/NewGraphDialog.java", templateContainer);
				createFile(new NewGraphDialogProperties(), basePath+presentationPath+resourcesPath+ "components/modals/graph/NewGraphDialog.properties", templateContainer);
				createFile(new RemoveGraphDialog(), basePath+presentationPath+componentsPath+ "components/modals/graph/RemoveGraphDialog.java", templateContainer);
				createFile(new AppModule(), basePath+presentationPath+componentsPath+ "services/AppModule.java", templateContainer);
				createFile(new ModelingCanvasProperties(), basePath+presentationPath+resourcesPath+ "components/canvas/ModelingCanvas.properties", templateContainer);
				createFile(new de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph.ModelingCanvas(), basePath+presentationPath+resourcesPath+ "components/canvas/ModelingCanvas.tml", templateContainer);
				createFile(new PyroTemplate(), basePath+presentationPath+componentsPath+ "pages/Pyro.java", templateContainer);
				
				// For all imported or referenced GraphModels
				for(GraphModel iteratorModel:graphModels) {
					
					String graphModelPath = toFirstLower(iteratorModel.getName()) + "/";
					
					templateContainer.setEdges(EdgeParser.getStyledEdges(iteratorModel,styles));
					templateContainer.setEnums(new ArrayList<Type>(iteratorModel.getTypes()));
					ArrayList<GraphicalModelElement> graphicalModelElements = new ArrayList<GraphicalModelElement>();
					graphicalModelElements.addAll(iteratorModel.getNodes());
					graphicalModelElements.addAll(iteratorModel.getNodeContainers());
					templateContainer.setNodes(NodeParser.getStyledNodes(iteratorModel,graphicalModelElements,styles));
					templateContainer.setGraphModel(iteratorModel);
					templateContainer.setGroupedNodes(ModelParser.getGroupedNodes(graphicalModelElements));
					templateContainer.setValidConnections(ModelParser.getValidConnections(iteratorModel));
					templateContainer.setEmbeddingConstraints(ModelParser.getValidEmbeddings(iteratorModel));
					
					
					createFile(new EditorCommunicatorTemplyte(), basePath+presentationPath +webappPath+ jsPath +graphModelPath+"pyro.communicator.js", templateContainer);
					createFile(new EditorModelTemplate(), basePath+presentationPath +webappPath+ jsPath +graphModelPath+"pyro.model.js", templateContainer);
					createFile(new EditorConstraintTemplate(), basePath+presentationPath +webappPath+ jsPath +graphModelPath+ "pyro.constraints.js", templateContainer);
					createFile(new EditorCSSTemplate(), basePath+presentationPath +webappPath+ cssPath +graphModelPath+ "pyro.nodes.css", templateContainer);
					
					//CustomActions
					//deleteFolder(basePath+businessPath+"custom/action/"+graphModelPath);
					for(Annotation annotation:iteratorModel.getAnnotations()){
						if(annotation.getName().equals("contextMenuAction")){
							createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.GraphCustomAction(), null,annotation, basePath+businessPath+"custom/action/"+graphModelPath+ ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
						}
					}for(StyledNode styledNode : templateContainer.getNodes()){
						for(Annotation annotation:styledNode.getModelElement().getAnnotations()){
							if(annotation.getName().equals("contextMenuAction")){
								createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.CustomAction(), styledNode,annotation, basePath+businessPath+"custom/action/"+graphModelPath+ ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
							}
						}
					}
					for(StyledEdge styledEdge : templateContainer.getEdges()){
						for(Annotation annotation:styledEdge.getModelElement().getAnnotations()){
							if(annotation.getName().equals("contextMenuAction")){
								createFile(new de.jabc.cinco.meta.plugin.pyro.templates.custom.action.CustomAction(), styledEdge,annotation, basePath+businessPath+"custom/action/"+graphModelPath+  ModelParser.getCustomActionName(annotation)+"CustomAction.java", templateContainer);							
							}
						}}
					
					//Parser
					deleteFolder(basePath+businessPath+"parser/"+graphModelPath);
					createFile(new GraphModelParser(),null, basePath+businessPath+"parser/"+graphModelPath+ iteratorModel.getName()+"Parser.java", templateContainer);
					for(StyledNode styledNode : templateContainer.getNodes()){
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.parser.NodeParser(), styledNode, basePath+businessPath+"parser/"+graphModelPath+ styledNode.getModelElement().getName()+"Parser.java", templateContainer);
					}
					for(StyledEdge styledEdge : templateContainer.getEdges()){
						createFile(new de.jabc.cinco.meta.plugin.pyro.templates.parser.EdgeParser(), styledEdge, basePath+businessPath+"parser/"+graphModelPath+ styledEdge.getModelElement().getName()+"Parser.java", templateContainer);
					}
					
					//Message
					deleteFolder(basePath+businessPath+ "message/"+graphModelPath);
					createFile(new CreateMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"CreateMessageParser.java", templateContainer);
					createFile(new RemoveMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"RemoveMessageParser.java", templateContainer);
					createFile(new MoveMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"MoveMessageParser.java", templateContainer);
					createFile(new EditMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"EditMessageParser.java", templateContainer);
					createFile(new ResizeMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"ResizeMessageParser.java", templateContainer);
					createFile(new RotateMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"RotateMessageParser.java", templateContainer);
					createFile(new AttributeMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"AttributeMessageParser.java", templateContainer);
					createFile(new CustomMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"CustomFeatureParser.java", templateContainer);
					createFile(new SettingsMessageParser(), basePath+businessPath+ "message/"+graphModelPath+"SettingsMessageParser.java", templateContainer);
					
					//Transformation
					deleteFolder(basePath+businessPath+"transformation/api/"+graphModelPath);
					createFile(new GraphWrapper(), basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"Wrapper.java", templateContainer);
					createFile(new GraphWrapperImpl(), basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"WrapperImpl.java", templateContainer);
					
					createFile(new CGraphModel(), basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+".java", templateContainer);
					createFile(new CGraphModelImpl(), basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ iteratorModel.getName()+"Impl.java", templateContainer);
					
					for(StyledNode styledNode : templateContainer.getNodes()){
						if(styledNode.getModelElement() instanceof mgl.NodeContainer){
							createFile(new CContainer(), styledNode, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+".java", templateContainer);
							createFile(new CContainerImpl(), styledNode, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+"Impl.java", templateContainer);
							
						}
						else{
							createFile(new CNode(), styledNode, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+".java", templateContainer);
							createFile(new CNodeImpl(), styledNode, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledNode.getModelElement().getName()+"Impl.java", templateContainer);
						}
					}
					for(StyledEdge styledEdge : templateContainer.getEdges()){
						createFile(new CEdge(), styledEdge, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledEdge.getModelElement().getName()+".java", templateContainer);
						createFile(new CEdgeImpl(), styledEdge, basePath+businessPath+"transformation/api/"+graphModelPath+"C"+ styledEdge.getModelElement().getName()+"Impl.java", templateContainer);
					}
					
					FileHandler.copyResources("de.jabc.cinco.meta.plugin.pyro",basePath);

				}
								
//				Thread thread = new Thread(){
//				    public void run(){
//				    	System.out.println("[Pyro] Deployemnt Started.");
//						try {
//							Runtime rt = Runtime.getRuntime();
//			                Process pr = rt.exec("xterm -iconic -hold -e bash "+basePath+"/deployment/deployCincoFTW.sh");
//			                while(!(pr.isAlive()));
//						} catch (IOException e) {
//							e.printStackTrace();
//						}
//						System.out.println("[Pyro] Deployemnt Terminated.");
//						
//				    }
//				};
//				thread.start();
				
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
		
		FileUtils.writeStringToFile(f, template.create(tc.getGraphModel(), tc.getNodes(), tc.getEdges(), tc.getGroupedNodes(), tc.getValidConnections(),tc.getEmbeddingConstraints(),tc.getEnums(),tc.getGraphModels(),tc.getEcores()).toString());
	}
	
	private void createFile(ElementTemplateable template,StyledModelElement sme,String path,TemplateContainer tc) throws IOException
	{
		File f = new File(path);
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(sme,tc.getGraphModel(), tc.getNodes(), tc.getEdges(), tc.getGroupedNodes(), tc.getValidConnections(),tc.getEmbeddingConstraints(),tc.getEnums()).toString());
	}
	private void createFile(AnnotationElementTemplateable template,StyledModelElement sme,mgl.Annotation anno,String path,TemplateContainer tc) throws IOException
	{
		File f = new File(path);
		if(f.exists() && !f.isDirectory()) {
			return;
		}
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(anno,sme,tc.getGraphModel(), tc.getNodes(), tc.getEdges(), tc.getGroupedNodes(), tc.getValidConnections(),tc.getEmbeddingConstraints(),tc.getEnums()).toString());
	}
	
	private void createFile(DefaultTemplate template,String path,Object ...objects) throws IOException
	{
		File f = new File(path);
		f.getParentFile().mkdirs(); 
		f.createNewFile();
		
		FileUtils.writeStringToFile(f, template.create(objects).toString());
	}
	
	public static void deleteFolder(String path) throws IOException {
		File folder = new File(path);
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
	
	private String toFirstUpper(String s) {
		return Character.toUpperCase(s.charAt(0)) + s.substring(1);
	}
	
	private String toFirstLower(String s) {
		return Character.toLowerCase(s.charAt(0)) + s.substring(1);
	}
	
	
}

