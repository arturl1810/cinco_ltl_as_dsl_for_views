package de.jabc.cinco.meta.core.ge.generator.action;

import graphicalgraphmodel.CContainer;
import graphicalgraphmodel.CGraphModel;
import graphicalgraphmodel.CModelElement;
import graphicalgraphmodel.CModelElementContainer;
import graphicalgraphmodel.GraphicalgraphmodelPackage;
import graphmodel.GraphmodelPackage;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.jar.Manifest;

import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.internal.runtime.InternalPlatform;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMIResource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.graphiti.datatypes.ILocation;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IDeleteFeature;
import org.eclipse.graphiti.features.IMoveShapeFeature;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.IUpdateFeature;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.features.context.impl.AddConnectionContext;
import org.eclipse.graphiti.features.context.impl.AddContext;
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;
import org.eclipse.graphiti.features.context.impl.DeleteContext;
import org.eclipse.graphiti.features.context.impl.MoveShapeContext;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.features.context.impl.ResizeContext;
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext;
import org.eclipse.graphiti.features.context.impl.UpdateContext;
import org.eclipse.graphiti.mm.algorithms.styles.Point;
import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.PictogramLink;
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory;
import org.eclipse.graphiti.platform.IDiagramBehavior;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.services.IGaService;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.services.GraphitiUi;
import org.eclipse.pde.core.project.IBundleProjectDescription;
import org.eclipse.pde.core.project.IBundleProjectService;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;
import org.eclipse.xtext.util.StringInputStream;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

import style.AbstractShape;
import style.Appearance;
import style.ConnectionDecorator;
import style.ContainerShape;
import style.EdgeStyle;
import style.GraphicsAlgorithm;
import style.Image;
import style.NodeStyle;
import style.Style;
import style.Styles;
import de.jabc.cinco.meta.core.ge.generator.Main;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoContainerCardinalityException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoEdgeCardinalityInException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoEdgeCardinalityOutException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoInvalidCloneTargetException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoInvalidContainerException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoInvalidSourceException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.CincoInvalidTargetException;
import de.jabc.cinco.meta.core.ge.style.model.errorhandling.ECincoError;
import de.jabc.cinco.meta.core.mgl.generator.GenModelCreator;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.URIHandler;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class GraphitiCodeGenerator extends AbstractHandler {

	private final String ID_ICON = "icon";
	private final String ID_STYLE = "style";
	private final String API_MODEL_PREFIX = "C";
	
	private String GMODEL_NAME_LOWER = "";
	
	
	private GraphModel gModel;
	private IProject sourceProject;
	private final String GRAPHICAL_GRAPH_MODEL_PATH = "/de.jabc.cinco.meta.core.ge.style.model/"
			+ "model/"
			+ "GraphicalGraphModel.genmodel";
	
	 
	public GraphitiCodeGenerator() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile file = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		
		if (file!=null) {
		
		
		sourceProject = file.getProject();
		NullProgressMonitor monitor = new NullProgressMonitor();
		
			
			Resource resource = new ResourceSetImpl().getResource(URI.createPlatformResourceURI(file.getFullPath().toOSString(), true), true);
		    Styles styles = null;
		    try {
		    	gModel = loadGraphModel(resource);
				
				for (Annotation a : gModel.getAnnotations()) {
					if (ID_STYLE.equals(a.getName())) {
						String stylePath = a.getValue().get(0);
						styles = loadStyles(stylePath, gModel);
					}
				}
				
				if (styles == null) {
					return null;
				}
				
				gModel = prepareGraphModel(gModel);
				
				GMODEL_NAME_LOWER = gModel.getName().toLowerCase();
				
				EPackage generatedGraphmodelPackage = getPackage(sourceProject, gModel.getName());
				
				String mglProjectName = file.getProject().getName();
				String projectName = file.getProject().getName();
				String apiProjectName = mglProjectName;
				String path = ResourcesPlugin.getWorkspace().getRoot().getLocation().append(projectName).toOSString() + "/plugin.xml";
				IFile pluginXMLFile = file.getProject().getFile("plugin.xml");
				if (pluginXMLFile.exists())
					path = pluginXMLFile.getLocation().toOSString();
				
				List<String> srcFolders = getSrcFolders();
				List<String> cleanDirs = getCleanDirectory();
			    
			    IProject p = sourceProject;
			    IProject apiProject = sourceProject; 
			    
			    addReqBundles(p, monitor);
			    
			    createIconsFolder(p, monitor);
			    copyImage(styles, p, monitor);
			    copyImage(gModel, p, monitor);
			    copyIcons("de.jabc.cinco.meta.core.ge.generator", p, monitor);
			    
			    try {
					p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
					apiProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
				} catch (CoreException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			    String outletPath = p.getFolder("src-gen").getLocation().makeAbsolute().toString();
			    String customFeatureOutletPath = p.getFolder("src").getLocation().makeAbsolute().toOSString();
				
			    /**
			     *	Get required information for Wrapper API meta model generation 
			     */
			    EPackage graphmodel = EPackage.Registry.INSTANCE.getEPackage(gModel.getNsURI());
			    EPackage graphicalGraphModel = EcoreUtil2.getEPackage("platform:/plugin/de.jabc.cinco.meta.core.ge.style.model/model/GraphicalGraphModel.ecore");
			    EPackage graphitiModel = EcoreUtil2.getEPackage("platform:/plugin/org.eclipse.graphiti.mm/model/graphiti.ecore");
			    PluginRegistry.getInstance().getRegisteredEcoreModels().put("graphicalGraphModel", graphicalGraphModel);
			    PluginRegistry.getInstance().getGenModelMap().put(graphicalGraphModel, "platform:/plugin/de.jabc.cinco.meta.core.ge.style.model/model/GraphicalGraphModel.genmodel");
			    PluginRegistry.getInstance().getRegisteredEcoreModels().put("graphitiModel", graphitiModel);
			    PluginRegistry.getInstance().getGenModelMap().put(graphitiModel, "platform:/plugin/org.eclipse.graphiti.mm/model/graphiti.genmodel");
			    
			    
			    URI uri = URI.createFileURI(API_MODEL_PREFIX + gModel.getName()+ ".ecore");
			    XMIResource graphicalGraphModelRes = (XMIResource) new XMIResourceFactoryImpl().createResource(uri);
			    
			    EDataType integerType = EcorePackage.eINSTANCE.getEInt();
			    EDataType booleanType = EcorePackage.eINSTANCE.getEBoolean();
			    
			    LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
				context.put("graphModel", gModel);
				context.put("styles", styles);
				context.put("mglProjectName", mglProjectName);
				context.put("projectName", projectName);
				context.put("pluginXMLPath", path);
				context.put("outletPath", outletPath);
				context.put("project", sourceProject);
				context.put("customFeatureOutletPath", customFeatureOutletPath);
				
				context.put("graphmodel", graphmodel);
				context.put("graphicalGraphModel", graphicalGraphModel);
				context.put("genmodelMap", PluginRegistry.getInstance().getGenModelMap());
				context.put("registeredGeneratorPlugins", PluginRegistry.getInstance().getPluginGenerators());
				context.put("registeredPackageMap", PluginRegistry.getInstance().getRegisteredEcoreModels());
				context.put("resource", graphicalGraphModelRes);
				
				context.put("gModelElementType", GraphicalgraphmodelPackage.eINSTANCE.getEClassifier("CModelElement"));
				context.put("gNodeType", GraphicalgraphmodelPackage.eINSTANCE.getEClassifier("CNode"));
				context.put("gEdgeType", GraphicalgraphmodelPackage.eINSTANCE.getEClassifier("CEdge"));
				context.put("gContainerType", GraphicalgraphmodelPackage.eINSTANCE.getEClassifier("CContainer"));
				context.put("gModelElementContainerType", GraphicalgraphmodelPackage.eINSTANCE.getEClassifier("CModelElementContainer"));
				context.put("nodeType", GraphmodelPackage.eINSTANCE.getEClassifier("Node"));
				context.put("edgeType", GraphmodelPackage.eINSTANCE.getEClassifier("Edge"));
				context.put("containerType", GraphmodelPackage.eINSTANCE.getEClassifier("Container"));
				context.put("modelElementContainerType", GraphmodelPackage.eINSTANCE.getEClassifier("ModelElementContainer"));
				context.put("globmodelElementType", GraphmodelPackage.eINSTANCE.getEClassifier("ModelElement"));
				context.put("apiPrefix", API_MODEL_PREFIX);
				
				context.put("integerType", integerType);
				context.put("booleanType", booleanType);
				context.put("eObjectType", EcorePackage.eINSTANCE.getEObject());
				context.put("genGraphModelPackage", generatedGraphmodelPackage);
				
				
				fqnToContext(context);
				
				LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
				context.put("ExecutionEnvironment", env);

				
				Main tmp = new Main();
				String result = tmp.execute(env);
				
				exportPackages(p, gModel, monitor);
				
				if (result.equals("default")) {
					EPackage ePackage = (EPackage) context.get("ePackage");
					String nsUri = ePackage.getNsURI();
					int index = nsUri.lastIndexOf("/");
					ePackage.setNsURI(nsUri.replace(nsUri.substring(index+1), API_MODEL_PREFIX.toLowerCase() + nsUri.substring(index+1)));
					EPackage.Registry.INSTANCE.put(ePackage.getNsURI(), ePackage);
					graphicalGraphModelRes.getContents().add(ePackage);
					ByteArrayOutputStream bops = new ByteArrayOutputStream();
					HashMap<String, Object>optionMap = new HashMap<String,Object>();
					optionMap.put(XMIResource.OPTION_URI_HANDLER,new URIHandler(ePackage));
								
					graphicalGraphModelRes.save(bops,optionMap);
					
					String output = bops.toString(graphicalGraphModelRes.getEncoding());
					String fqn = gModel.getName();
					IFolder folder = apiProject.getFolder("/src-gen/model");
					if (!folder.exists())
						folder.create(true, true, monitor);
					String ecorePath = "/src-gen/model/"+API_MODEL_PREFIX + fqn.substring(0, 1).toUpperCase() + fqn.substring(1) + ".ecore";
					IFile iEcoreFile = apiProject.getFile(ecorePath);
					if (!iEcoreFile.exists())
						iEcoreFile.create(new ByteArrayInputStream(output.getBytes()), true, monitor);
					else iEcoreFile.setContents(new ByteArrayInputStream(output.getBytes()), true, true, monitor);
					IPath projectPath = new Path(apiProjectName);
					
					/**
					 * Get project ID
					 */
					
					BundleContext bc = InternalPlatform.getDefault().getBundleContext();
					ServiceReference<?> ref = bc.getServiceReference(IBundleProjectService.class);
					IBundleProjectService service = (IBundleProjectService) bc.getService(ref);  
					IBundleProjectDescription bpd =service.getDescription(apiProject);
					String projectID = bpd.getSymbolicName();
					bc.ungetService(ref);
					
					GenModel genModel = GenModelCreator.createGenModel(new Path(ecorePath),ePackage,apiProjectName, projectID, projectPath);
					if(gModel.getPackage() !=null && gModel.getPackage().length()>0){
						for(GenPackage genPackage : genModel.getGenPackages()){
							genPackage.setBasePackage(gModel.getPackage() +".api");
						}
					}
					
					IResource iRes = sourceProject.getFile("/src-gen/model/" + gModel.getName() + ".genmodel");
					if (iRes.exists()) {
						Resource generatedGenModel = new ResourceSetImpl().getResource(
									URI.createFileURI(iRes.getLocation().toOSString()),
									true );
						for (EObject o : generatedGenModel.getContents()) {
							if (o instanceof GenModel)
								genModel.getUsedGenPackages().addAll(((GenModel) o).getGenPackages());
						}
					}
					
					
					Resource generatedGenModel = new ResourceSetImpl().getResource(
								URI.createPlatformPluginURI(
										GRAPHICAL_GRAPH_MODEL_PATH , true),
								true );
					for (EObject o : generatedGenModel.getContents()) {
						if (o instanceof GenModel)
							genModel.getUsedGenPackages().addAll(((GenModel) o).getGenPackages());
					}
					
					bops = new ByteArrayOutputStream();
					uri = URI.createFileURI(API_MODEL_PREFIX + gModel.getName().toString()+".genmodel");
					XMIResourceImpl xmiResource = (XMIResourceImpl) new XMIResourceFactoryImpl().createResource(uri);
					xmiResource.getContents().add(genModel);
					xmiResource.save(bops,null);
					output = bops.toString(xmiResource.getEncoding());
					String genModelPath = "/src-gen/model/"+ API_MODEL_PREFIX + fqn.substring(0, 1).toUpperCase() + fqn.substring(1) +".genmodel";
					IFile genModelFile = apiProject.getFile(genModelPath);
					if (!genModelFile.exists())
						genModelFile.create(new ByteArrayInputStream(output.getBytes()), true, monitor);
					else genModelFile.setContents(new ByteArrayInputStream(output.getBytes()), true, true, monitor);
					apiProject.refreshLocal(IResource.DEPTH_INFINITE, monitor);
				}
				
				if (result.equals("error")) {
					Exception e = (Exception) context.get("exception");
					throw new ExecutionException(e.getMessage());
				}
				
				p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
				
			} catch (IOException e) {
				e.printStackTrace();
			} catch (CoreException e) {
				e.printStackTrace();
			}
		}
		return null;
	}
	
	private void fqnToContext(LightweightExecutionContext context) {
		context.put("fqnIPath", IPath.class.getName());
		context.put("fqnIFile", IFile.class.getName());
		context.put("fqnURI", URI.class.getName());
		context.put("fqnResource", Resource.class.getName());
		context.put("fqnResourceSetImpl", ResourceSetImpl.class.getName());
		context.put("fqnResourcesPlugin", ResourcesPlugin.class.getName());
		context.put("fqnNullProgressMonitor", NullProgressMonitor.class.getName());
		context.put("fqnStringInputStream", StringInputStream.class.getName());
		context.put("fqnIOException", IOException.class.getName());
		context.put("fqnCoreException", CoreException.class.getName());
		context.put("fqnCincoContainerCardinalityException", CincoContainerCardinalityException.class.getName());
		context.put("fqnCincoEdgeCardinalityInException", CincoEdgeCardinalityInException.class.getName());
		context.put("fqnCincoEdgeCardinalityOutException", CincoEdgeCardinalityOutException.class.getName());
		context.put("fqnCincoInvalidCloneTargetException", CincoInvalidCloneTargetException.class.getName());
		context.put("fqnCincoInvalidContainerException", CincoInvalidContainerException.class.getName());
		context.put("fqnCincoInvalidSourceException", CincoInvalidSourceException.class.getName());
		context.put("fqnCincoInvalidTargetException", CincoInvalidTargetException.class.getName());
		context.put("fqnECincoError", ECincoError.class.getName());
		context.put("fqnTransactionalEditingDomain", TransactionalEditingDomain.class.getName());
		context.put("fqnTransactionUtil", TransactionUtil.class.getName());
		context.put("fqnRecordingCommand", RecordingCommand.class.getName());
		context.put("fqnArrayList", ArrayList.class.getName());
		context.put("fqnSet", Set.class.getName());
		
		context.put("fqnDiagram", Diagram.class.getName());
		context.put("fqnDiagramBehavior", DiagramBehavior.class.getName());
		context.put("fqnIDiagramBehavior", IDiagramBehavior.class.getName());
		context.put("fqnDiagramTypeProvider", IDiagramTypeProvider.class.getName());
		
		context.put("fqnGraphiti", Graphiti.class.getName());
		context.put("fqnGaService", IGaService.class.getName());
		context.put("fqnGraphitiUi", GraphitiUi.class.getName());
		context.put("fqnFeatureProvider", gModel.getPackage() + ".graphiti." + gModel.getName() + "FeatureProvider");
		context.put("fqnShape", org.eclipse.graphiti.mm.pictograms.Shape.class.getName());
		context.put("fqnContainerShape", org.eclipse.graphiti.mm.pictograms.ContainerShape.class.getName());
		context.put("fqnConnection", org.eclipse.graphiti.mm.pictograms.Connection.class.getName());
		context.put("fqnFreeFormConnection", org.eclipse.graphiti.mm.pictograms.FreeFormConnection.class.getName());
		context.put("fqnPoint", Point.class.getName());
		context.put("fqnPictogramElement", PictogramElement.class.getName());
		context.put("fqnPictogramLink", PictogramLink.class.getName());
		context.put("fqnPictogramsFactory", PictogramsFactory.class.getName());
		context.put("fqnILocation", ILocation.class.getName());
		context.put("fqnAnchor", Anchor.class.getName());
		
		context.put("fqnAddContext", AddContext.class.getName());
		context.put("fqnAddConnectionContext", AddConnectionContext.class.getName());
		context.put("fqnCreateContext", CreateContext.class.getName());
		context.put("fqnCreateConnectionContext", CreateConnectionContext.class.getName());
		context.put("fqnDeleteContext", DeleteContext.class.getName());
		context.put("fqnMoveShapeContext", MoveShapeContext.class.getName());
		context.put("fqnReconnectionContext", ReconnectionContext.class.getName());
		context.put("fqnResizeShapeContext", ResizeShapeContext.class.getName());
		context.put("fqnUpdateContext", UpdateContext.class.getName());
		
		context.put("fqnAPIPrefix", gModel.getPackage() +".api." + API_MODEL_PREFIX.toLowerCase() + GMODEL_NAME_LOWER + ".");
		context.put("fqnAPIFactory", gModel.getPackage() +".api." + API_MODEL_PREFIX.toLowerCase() + GMODEL_NAME_LOWER + "." + API_MODEL_PREFIX + GMODEL_NAME_LOWER + "Factory");
		context.put("fqnGraphitiUtils", gModel.getPackage() + ".graphiti." + gModel.getName()+"GraphitiUtils");
		context.put("fqnCModelElementContainer", CModelElementContainer.class.getName());
		context.put("fqnCModelElement", CModelElement.class.getName());
		context.put("fqnCContainer", CContainer.class.getName());
		context.put("fqnCGraphModel", CGraphModel.class.getName());
		context.put("fqnNode", graphmodel.Node.class.getName());
		context.put("fqnEdge", graphmodel.Edge.class.getName());
		context.put("fqnContainer", graphmodel.Container.class.getName());
		context.put("fqnModelElement", graphmodel.ModelElement.class.getName());
		context.put("fqnModelElementContainer", graphmodel.ModelElementContainer.class.getName());
		
		context.put("fqnDeleteFeature", IDeleteFeature.class.getName());
		context.put("fqnMoveShapeFeature", IMoveShapeFeature.class.getName());
		context.put("fqnReconnectionFeature", IReconnectionFeature.class.getName());
		context.put("fqnUpdateFeature", IUpdateFeature.class.getName());
		
		context.put("fqnCreateNodeFeaturePrefix", gModel.getPackage().concat(".graphiti.features.create.nodes."));
		context.put("fqnCreateEdgeFeaturePrefix", gModel.getPackage().concat(".graphiti.features.create.edges."));
		context.put("fqnCreateContainerFeaturePrefix", gModel.getPackage().concat(".graphiti.features.create.containers."));
		context.put("fqnAddFeaturePrefix", gModel.getPackage().concat(".graphiti.features.add."));
		context.put("fqnMoveFeaturePrefix", gModel.getPackage().concat(".graphiti.features.move."));
		context.put("fqnFeaturePrefix", gModel.getPackage().concat(".graphiti.features."));
		context.put("fqnReconnectPrefix", gModel.getPackage().concat(".graphiti.features.reconnect."));
		context.put("fqnResizePrefix", gModel.getPackage().concat(".graphiti.features.resize."));
		
		context.put("fqnGenNodePrefix", gModel.getPackage() + "." + GMODEL_NAME_LOWER +".");
		context.put("fqnGenEdgePrefix", gModel.getPackage() + "." + GMODEL_NAME_LOWER +".");
		context.put("fqnGenContainerPrefix", gModel.getPackage() + "." + GMODEL_NAME_LOWER +".");
		context.put("fqnGenModelPrefix", gModel.getPackage() + "." + GMODEL_NAME_LOWER +".");
	}

	/**
	 * This method copies all images that are defined in the {@link styles}
	 * @param styles The processed Styles object
	 * @param p The target project. Usually the Graphiti project
	 * @param monitor Progress monitor
	 */
	private void copyImage(Styles styles, IProject p, NullProgressMonitor monitor) {
		for (Style s : styles.getStyles()) {
			if (s instanceof NodeStyle) {
				copyAbstractShapeImages(((NodeStyle) s).getMainShape(), p, monitor);
			}
			
			if (s instanceof EdgeStyle) {
				copyEdgeDecoratorImages(((EdgeStyle) s).getDecorator(), p, monitor);
			}
		}
		
		for (Appearance ap : styles.getAppearances()) {
			copyImage(ap.getImagePath(), p, monitor);
		}
		
	}
	
	private void copyImage(GraphModel gm, IProject p, NullProgressMonitor monitor) {
		copyImages(gm.getAnnotations(), p, monitor);
		copyImage(gm.getIconPath(), p, monitor);
		for (Node n : gm.getNodes()) 
			copyImages(n.getAnnotations(), p, monitor);
		
		for (Edge e : gm.getEdges())
			copyImages(e.getAnnotations(), p, monitor);
		
		for (NodeContainer nc : gm.getNodeContainers())
			copyImages(nc.getAnnotations(), p, monitor);
	}

	private void copyImages(List<Annotation> annots, IProject p, NullProgressMonitor monitor) {
		for (Annotation a : annots) {
			if (ID_ICON.equals(a.getName()) && a.getValue().size() != 0) {
				copyImage(a.getValue().get(0), p, monitor);
			}
		}
	}
	
	private void createIconsFolder(IProject p, NullProgressMonitor monitor) {
		IFolder icons = p.getFolder("icons");
		IFolder resGen = p.getFolder(new Path("resources-gen"));
		IFolder icoGen = p.getFolder(new Path("resources-gen/icons"));
		try {
		if (!resGen.exists())
			resGen.create(true, true, monitor);
		if (!icoGen.exists())
			icoGen.create(true, true, monitor);
		if (!icons.exists()) 
			icons.create(true, true, monitor);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void copyEdgeDecoratorImages(List<ConnectionDecorator> decorators, IProject p, NullProgressMonitor monitor) {
		for (ConnectionDecorator cd : decorators) {
			GraphicsAlgorithm shape = cd.getDecoratorShape();
			if (shape instanceof Image) {
				Image img = (Image) shape;
				copyImage(img.getPath(), p, monitor);
			}
		}
	}

	private void copyAbstractShapeImages(AbstractShape s, IProject p, NullProgressMonitor monitor) {
		if (s instanceof ContainerShape) {
			for (AbstractShape as : ((ContainerShape) s).getChildren()) {
				copyAbstractShapeImages(as, p, monitor);
			}
		}
		
		if (s instanceof Image) {
			Image img = (Image) s;
			copyImage(img.getPath(), p, monitor);
		}
		
	}

	private void copyImage(String path, IProject target, NullProgressMonitor monitor) {
		if (path == null || path.isEmpty())
			return;
//		IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
		URI iconURI = URI.createURI(path);
		IFile iconFile = null;
		try {
			if (iconURI.isPlatformResource()) {
				iconFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(iconURI.toPlatformString(true)));
				IFolder iconsGen = target.getFolder("resources-gen/icons");
				String newFileName = iconURI.path().replaceAll("/", "_");
				if (!iconsGen.getFile(newFileName).exists()) 
					iconFile.copy(iconsGen.getFullPath().append(newFileName), true, monitor);
			}
		} catch (CoreException e ) {
			e.printStackTrace();
		}
//		} else {
//			IResource res = workspaceRoot.findMember(iconURI.toPlatformString(true));
//			if (res instanceof IFile) {
//				iconFile = (IFile) res;
//			}
//		}
//		try {
//			IFolder icons = target.getFolder("icons");
//			IFolder iconsGen = target.getFolder("resources-gen/icons");
//			if (!icons.exists())
//				icons.create(true, true, monitor);
//			IFile file = icons.getFile(iconFile.getLocation());
//			IFile fileGen = iconsGen.getFile(iconFile.getLocation());
//			if ( (file == null || !file.exists()) && (fileGen == null || !fileGen.exists()) )
//				iconFile.copy(iconsGen.getFullPath().append(iconFile.getName()), true, monitor);
//		} catch (CoreException e) {
//			e.printStackTrace();
//		}
		
	}

	private Styles loadStyles(String path, GraphModel gm) throws IOException {
//		URI resourceUri = gm.eResource().getURI();
//		IProject project = ResourcesPlugin.getWorkspace().getRoot().getProject(resourceUri.toPlatformString(true));
//		Resource stylesResource = CincoUtils.getStylesResource(path, project);
//		for (EObject o : stylesResource.getContents()) {
//			if (o instanceof Styles)
//				return (Styles) o;
//		}
//		return null;
		
//		/**			This code part was swapped to CincoUtils class...
		Resource res = null;
		
		URI uri = URI.createURI(path, true);
		try {
			res = null;
			if (uri.isPlatformResource())
				res = new ResourceSetImpl().getResource(uri, true);
			else {
				IProject p = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(gm.eResource().getURI().toPlatformString(true))).getProject();
				IFile file = p.getFile(path);
				URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
				res = new ResourceSetImpl().getResource(fileURI, true);
			}
			
			for (Object o : res.getContents()) {
				if (o instanceof Styles)
					return (Styles) o;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return null;
//		**/
	}
	
	private GraphModel loadGraphModel(Resource res) throws IOException{
		if (res == null)
			throw new IOException("Resource is null");
		if (res.getContents().get(0) instanceof GraphModel) {
			return (GraphModel) res.getContents().get(0);
		} else {
			throw new IOException("Could not load GraphModel (mgl) from resource: "+res);
		}
	}
	
	private void addReqBundles(IProject p, IProgressMonitor monitor) {
		Set<Bundle> bundles = new HashSet<Bundle>();

		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.resources"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
		bundles.add(Platform.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"));
		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));
		try {
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			ProjectCreator.addRequiredBundle(p, bundles);
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private List<String> getSrcFolders() {
		ArrayList<String> folders = new ArrayList<String>();
		folders.add("src");
		folders.add("src-gen");
		return folders;
	}

	private List<String> getCleanDirectory() {
		ArrayList<String> cleanDirs = new ArrayList<String>();
//		cleanDirs.add("src-gen");
//		cleanDirs.add("icons");
		return cleanDirs;
	}

	private void copyIcons(String bundleId, IProject p, IProgressMonitor monitor) {
		Bundle b = Platform.getBundle(bundleId);
		InputStream fis=null;
		try {
			fis = FileLocator.openStream(b, new Path("/icons/_Connection.gif"), false);
			File trgFile = p.getFolder("resources-gen/icons").getFile("_Connection.gif").getLocation().toFile();
			trgFile.createNewFile();
			OutputStream os = new FileOutputStream(trgFile);
			int bt;
			while ((bt = fis.read()) != -1) {
				os.write(bt);
			}
			fis.close();
			os.flush();
			os.close();
			
			
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private EPackage getPackage(IProject p, String gName) {
		IFile ecoreFile= p.getFolder(new Path("src-gen").append(new Path("model"))).getFile(gName.concat(".ecore"));
		if (ecoreFile != null && ecoreFile.exists()) {
			Resource res = new ResourceSetImpl().getResource(URI.createFileURI(ecoreFile.getLocation().toOSString()), true);
			for (TreeIterator<EObject> it = res.getAllContents(); it.hasNext();) {
				EObject next = it.next();
				if (next instanceof EPackage)
					return (EPackage) next;
			}
		}
		return null;
	}
	
	private void exportPackages(IProject p, GraphModel gm, NullProgressMonitor monitor ) {
		IFile iManiFile= p.getFolder("META-INF").getFile("MANIFEST.MF");
		try {
			iManiFile.refreshLocal(IFile.DEPTH_INFINITE, monitor);
			Manifest manifest = new Manifest(iManiFile.getContents());
			String prefix = gm.getPackage();
			boolean primeOnly = true, noEdges = true;
			for (Node n : gm.getNodes())
				if (!n.isIsAbstract() && n.getPrimeReference() == null)
					primeOnly = false;
			
			ArrayList<String> exports = new ArrayList<>();
			if (gm.getNodeContainers().size() != 0)
				exports.add(".features.create.containers");
			if (!primeOnly)
				exports.add(".features.create.nodes");
			if (!noEdges)
				exports.add("features.create.edges");
			
			String val = manifest.getMainAttributes().getValue("Export-Package");
			if (val == null){
				val = new String("");
			} 
			
			val = removeExports(val, prefix);
			
			if (!val.contains(prefix+".graphiti"))
				if (val.isEmpty())
					val = val.concat(prefix+".graphiti");
				else val = val.concat(","+prefix+".graphiti");
			
			for (String s : exports) {
				if (!val.contains(","+prefix+".graphiti" + s))
					val += ","+prefix+".graphiti" + s;
			}
			manifest.getMainAttributes().putValue("Export-Package", val);
			
			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
		}
	}

	private String removeExports(String val, String prefix) {
		StringBuilder sb = new StringBuilder(val);
		int offset, end;
		if ((offset = sb.indexOf(","+prefix+".graphiti.features.create.nodes")) != -1) {
			end = new String(","+prefix+".graphiti.features.create.nodes").length();
			sb.delete(offset, offset+end);
		}
		if ((offset = sb.indexOf(","+prefix+".graphiti.features.create.edges")) != -1) {
			end = new String(","+prefix+".graphiti.features.create.edges").length();
			sb.delete(offset, offset+end);
		}
		if ((offset = sb.indexOf(","+prefix+".graphiti.features.create.containers")) != -1) {
			end = new String(","+prefix+".graphiti.features.create.containers").length();
			sb.delete(offset, offset+end);
		}
		
		return sb.toString();
	}
	
	private GraphModel prepareGraphModel(GraphModel graphModel){
		List<GraphicalModelElement> connectableElements = new ArrayList<>();
		
		connectableElements.addAll(graphModel.getNodes());
		connectableElements.addAll(graphModel.getNodeContainers());
		for(GraphicalModelElement elem : connectableElements) {
			for(IncomingEdgeElementConnection connect : elem.getIncomingEdgeConnections()){
				if(connect.getConnectingEdges() == null || connect.getConnectingEdges().isEmpty()){
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
			for(OutgoingEdgeElementConnection connect : elem.getOutgoingEdgeConnections()){
				if(connect.getConnectingEdges() == null || connect.getConnectingEdges().isEmpty()){
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
		}
		
		return graphModel;
	}
	
}
