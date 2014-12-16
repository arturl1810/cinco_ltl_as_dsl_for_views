package de.jabc.cinco.meta.core.ge.generator.action;

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
import mgl.Node;
import mgl.NodeContainer;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.internal.runtime.InternalPlatform;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
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
import org.eclipse.graphiti.features.context.impl.AddContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.services.GraphitiUi;
import org.eclipse.pde.core.plugin.IExtensions;
import org.eclipse.pde.core.plugin.IPluginBase;
import org.eclipse.pde.core.plugin.IPluginExtensionPoint;
import org.eclipse.pde.core.plugin.IPluginModelBase;
import org.eclipse.pde.core.project.IBundleProjectDescription;
import org.eclipse.pde.core.project.IBundleProjectService;
import org.eclipse.pde.internal.core.plugin.PluginExtension;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;
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
	private final String API_MODEL_PREFIX = "G";
	
	private String GMODEL_NAME_LOWER = "";
	
	
	private GraphModel gModel;
	private IProject sourceProject;
	
	
	public GraphitiCodeGenerator() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile file = MGLSelectionListener.INSTANCE.getSelectedFile();
		
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
				
				GMODEL_NAME_LOWER = gModel.getName().toLowerCase();
				
				String mglProjectName = file.getProject().getName();
//				String projectName = gModel.getPackage().concat(".graphiti");
				String projectName = gModel.getPackage();
//				String apiProjectName = projectName.concat(".api");
				String apiProjectName = mglProjectName;
				String path = ResourcesPlugin.getWorkspace().getRoot().getLocation().append(projectName).toOSString();
				
				
				List<String> srcFolders = getSrcFolders();
				List<String> cleanDirs = getCleanDirectory();
			    Set<String> reqBundles = getReqBundles();
			    String bundleName = ProjectCreator.getProjectSymbolicName(file.getProject());
			    reqBundles.add(bundleName);
			    
			    IProject p = ProjectCreator.createProject(projectName, srcFolders, null, reqBundles, null, null, monitor, cleanDirs, false);
			    reqBundles.add(p.getName());
//			    IProject apiProject = ProjectCreator.createProject(apiProjectName, srcFolders, null, reqBundles, null, null, monitor, cleanDirs, false);
			    IProject apiProject = sourceProject; 
			    
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
			    EPackage graphicalGraphModel = EcoreUtil2.getEPackage("platform:/plugin/de.jabc.cinco.meta.core.ge.style.model/model/GraphicalGraphModel.ecore");
			    EPackage graphitiModel = EcoreUtil2.getEPackage("platform:/plugin/org.eclipse.graphiti.mm/model/graphiti.ecore");
			    PluginRegistry.getInstance().getRegisteredEcoreModels().put("graphicalGraphModel", graphicalGraphModel);
			    PluginRegistry.getInstance().getGenModelMap().put(graphicalGraphModel, "platform:/plugin/de.jabc.cinco.meta.core.ge.style.model/model/GraphicalGraphModel.genmodel");
			    PluginRegistry.getInstance().getRegisteredEcoreModels().put("graphitiModel", graphitiModel);
			    PluginRegistry.getInstance().getGenModelMap().put(graphitiModel, "platform:/plugin/org.eclipse.graphiti.mm/model/graphiti.genmodel");
			    URI uri = URI.createFileURI(API_MODEL_PREFIX + gModel.getName()+ ".ecore");
			    XMIResource graphicalGraphModelRes = (XMIResource) new XMIResourceFactoryImpl().createResource(uri);
			    
			    EDataType integerType = EcorePackage.eINSTANCE.getEInt();
			    
			    LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
				context.put("graphModel", gModel);
				context.put("styles", styles);
				context.put("mglProjectName", mglProjectName);
				context.put("projectName", projectName);
				context.put("fullPath", path);
				context.put("outletPath", outletPath);
				context.put("customFeatureOutletPath", customFeatureOutletPath);
				
				context.put("graphicalGraphModel", graphicalGraphModel);
				context.put("genmodelMap", PluginRegistry.getInstance().getGenModelMap());
				context.put("registeredGeneratorPlugins", PluginRegistry.getInstance().getPluginGenerators());
				context.put("registeredPackageMap", PluginRegistry.getInstance().getRegisteredEcoreModels());
				context.put("resource", graphicalGraphModelRes);
				
				context.put("integerType", integerType);
				
				fqnToContext(context);
				
				LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
				context.put("ExecutionEnvironment", env);

				
				Main tmp = new Main();
				String result = tmp.execute(env);
				
				exportPackages(p, gModel, monitor);
				
//				IPluginModelBase model = org.eclipse.pde.core.plugin.PluginRegistry.findModel(mglProjectName);
//				IExtensions ext = model.getExtensions();
//				IPluginBase base = model.getPluginBase();
//				PluginExtension pluginExtension = new PluginExtension();
//				pluginExtension.setPoint("this.is.some.point");
//				base.add(pluginExtension);
//				for (IPluginExtensionPoint exp : ext.getExtensionPoints()) {
//					System.out.println(exp);
//				}
				
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
					
					Set<EPackage> usedEcoreModels = (Set<EPackage>) context.get("usedEcoreModels");
					HashMap<EPackage, String> genModelMap = PluginRegistry.getInstance().getGenModelMap();
					for(Object key : usedEcoreModels){
						if (key == null) 
							continue;
						String genuri = genModelMap.get(key);
						XMIResource res = new XMIResourceImpl(URI.createURI(genuri)); 
						res.load(null);
						
						TreeIterator<EObject> it = res.getAllContents();
						
						while (it.hasNext()){
							EObject o = it.next();
							if (o instanceof GenPackage) {
								System.out.println("Adding GenPackage: " + ((GenPackage) o));
								genModel.getUsedGenPackages().add((GenPackage) o);
							}
						}
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
		context.put("fqnDiagram", Diagram.class.getName());
		context.put("fqnPictogramElement", PictogramElement.class.getName());
		context.put("fqnAddContext", AddContext.class.getName());
		context.put("fqnCreateContext", CreateContext.class.getName());
		context.put("fqnContainerShape", org.eclipse.graphiti.mm.pictograms.ContainerShape.class.getName());
		context.put("fqnGraphitiUi", GraphitiUi.class.getName());
		context.put("fqnFeatureProvider", gModel.getPackage() + ".graphiti." + gModel.getName() + "FeatureProvider");
		context.put("fqnAPIFactory", gModel.getPackage() +".api.g" + GMODEL_NAME_LOWER + ".G" + GMODEL_NAME_LOWER + "Factory");
		context.put("fqnNode", graphmodel.Node.class.getName());
		
		context.put("fqnCreateNodeFeaturePrefix", gModel.getPackage().concat(".graphiti.features.create.nodes."));
		context.put("fqnGenNodePrefix", gModel.getPackage() + "." + GMODEL_NAME_LOWER +".");
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
		if (!icons.exists()) {
			try {
				icons.create(true, true, monitor);
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
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
		IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
		URI iconURI = URI.createURI(path);
		IFile iconFile = null;
		if (!iconURI.isPlatformResource()) {
			iconFile = sourceProject.getFile(path);
		} else {
			IResource res = workspaceRoot.findMember(iconURI.toPlatformString(true));
			if (res instanceof IFile) {
				iconFile = (IFile) res;
			}
		}
		try {
			IFolder icons = target.getFolder("icons");
			if (!icons.exists())
				icons.create(true, true, monitor);
			iconFile.copy(target.getFolder("icons").getFullPath().append(iconFile.getName()), true, monitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}

	private Styles loadStyles(String path, GraphModel gm) throws IOException {
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
	
	private Set<String> getReqBundles() {
		HashSet<String> reqBundles = new HashSet<String>();
		List<Bundle> bundles = new ArrayList<Bundle>();

		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
//		bundles.add(Platform.getBundle("org.eclipse.graphiti"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.resources"));
//		bundles.add(Platform.getBundle("org.eclipse.core.runtime"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
//		bundles.add(Platform.getBundle("org.eclipse.ui.navigator"));
		bundles.add(Platform.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
//		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.mgl.model"));
//		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"));
//		
		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));

		for (Bundle b : bundles) {
			StringBuilder s = new StringBuilder();
			s.append(b.getSymbolicName());
//			s.append(";bundle-version=");
//			s.append("\"" + b.getVersion().getMajor() + "."
//					+ b.getVersion().getMinor() + "."
//					+ b.getVersion().getMicro() + "\"");
			reqBundles.add(s.toString());
		}
		return reqBundles;
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
			File trgFile = p.getFolder("icons").getFile("_Connection.gif").getLocation().toFile();
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
	
	
	private void exportPackages(IProject p, GraphModel gm, NullProgressMonitor monitor ) {
		IFile iManiFile= p.getFolder("META-INF").getFile("MANIFEST.MF");
		try {
			Manifest manifest = new Manifest(iManiFile.getContents());
			String prefix = gm.getPackage();
			
			String[] exports;
			if (gm.getNodeContainers().size() != 0)
				exports = new String[] {
					".features.create.nodes",
					".features.create.edges",
					".features.create.containers"};
			else exports = new String[] {
					".features.create.nodes",
					".features.create.edges"};
			
			String val = manifest.getMainAttributes().getValue("Export-Package");
			String newVal;
			if (val == null){
				val = new String();
				newVal = val.concat(prefix+".graphiti");
			} else {
				newVal = val.concat(","+prefix+".graphiti");
			}
			for (String s : exports) {
				newVal += ","+prefix+".graphiti" + s;
			}
			manifest.getMainAttributes().putValue("Export-Package", newVal);
			
			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
			p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
		}
	}
	
}
