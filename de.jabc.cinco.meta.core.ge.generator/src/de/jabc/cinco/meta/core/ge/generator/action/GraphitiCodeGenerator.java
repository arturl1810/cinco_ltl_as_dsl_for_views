package de.jabc.cinco.meta.core.ge.generator.action;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import mgl.Import;
import mgl.Node;
import mgl.NodeContainer;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;
import org.osgi.framework.Bundle;

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
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class GraphitiCodeGenerator extends AbstractHandler {

	private final String ID_ICON = "icon";
	private final String ID_STYLE = "style";
	
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
				
				String mglProjectName = file.getProject().getName();
				String projectName = gModel.getPackage().concat(".graphiti");
				String path = ResourcesPlugin.getWorkspace().getRoot().getLocation().append(projectName).toOSString();
				
				List<String> srcFolders = getSrcFolders();
				List<String> cleanDirs = getCleanDirectory();
			    Set<String> reqBundles = getReqBundles();
			    String bundleName = ProjectCreator.getProjectSymbolicName(file.getProject());
			    reqBundles.add(bundleName);
			    IProject p = ProjectCreator.createProject(projectName, srcFolders, null, reqBundles, null, null, monitor, cleanDirs, false);
			    createIconsFolder(p, monitor);
			    copyImage(styles, p, monitor);
			    copyImage(gModel, p, monitor);
			    copyIcons("de.jabc.cinco.meta.core.ge.generator", p, monitor);
			    
			    try {
					p.refreshLocal(IResource.DEPTH_INFINITE, monitor);
				} catch (CoreException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			    String outletPath = p.getFolder("src-gen").getLocation().makeAbsolute().toString();
			    String customFeatureOutletPath = p.getFolder("src").getLocation().makeAbsolute().toOSString();
				
				LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
				context.put("graphModel", gModel);
				context.put("styles", styles);
				context.put("mglProjectName", mglProjectName);
				context.put("projectName", projectName);
				context.put("fullPath", path);
				context.put("outletPath", outletPath);
				context.put("customFeatureOutletPath", customFeatureOutletPath);
				LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
				
				Main tmp = new Main();
				String result = tmp.execute(env);
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
	

	
	private Collection<? extends GenPackage> getUsedGenPackages() {
		if (gModel == null)
			return Collections.emptyList();
		List<GenPackage> genPackages = new ArrayList<>();
		for (Import _import : gModel.getImports()) {
			String impString = _import.getImportURI();
			EPackage ePackage = EcoreUtil2.getEPackage(impString);
			Map<String, URI> map = EcorePlugin.getEPackageNsURIToGenModelLocationMap(true);
			URI genModelUri = map.get(ePackage.getNsURI());
			
			if (genModelUri.isRelative())
				genModelUri = URI.createPlatformResourceURI(genModelUri.toPlatformString(true), true);
			
			Resource res = new ResourceSetImpl().getResource(genModelUri, true);
			TreeIterator<EObject> it = res.getAllContents();
			while (it.hasNext()) {
				EObject object = it.next();
				if (object instanceof GenPackage) {
					if (((GenPackage) object).getNSURI().equals(ePackage.getNsURI())) {
						genPackages.add((GenPackage) object);
					} else if (object instanceof GenModel) {
						it.prune();
					}
					System.out.println(genModelUri);
				}
			}
		
		}
		return genPackages;
	}
	private Set<String> getReqBundles() {
		HashSet<String> reqBundles = new HashSet<String>();
		List<Bundle> bundles = new ArrayList<Bundle>();

		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.runtime"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
		bundles.add(Platform.getBundle("org.eclipse.ui.navigator"));
		bundles.add(Platform
				.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.mgl.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"));
		
		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));

		for (Bundle b : bundles) {
			StringBuilder s = new StringBuilder();
			s.append(b.getSymbolicName());
			s.append(";bundle-version=");
			s.append("\"" + b.getVersion().getMajor() + "."
					+ b.getVersion().getMinor() + "."
					+ b.getVersion().getMicro() + "\"");
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
		cleanDirs.add("src-gen");
		cleanDirs.add("icons");
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
			// TODO Auto-generated catch block
			
			e.printStackTrace();
		}
	}
}
