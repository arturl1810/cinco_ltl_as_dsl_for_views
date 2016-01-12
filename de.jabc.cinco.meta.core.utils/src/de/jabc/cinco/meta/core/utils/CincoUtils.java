package de.jabc.cinco.meta.core.utils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import mgl.Annotation;
import mgl.Attribute;
import mgl.GraphModel;
import mgl.Import;
import mgl.ModelElement;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.Style;
import style.Styles;


public class CincoUtils {

	public static final String ID_STYLE = "style";
	public static final String ID_ICON = "icon";
	public static final String ID_DISABLE= "disable";
	public static final String ID_DISABLE_CREATE = "create";
	public static final String ID_DISABLE_DELETE = "delete";
	public static final String ID_DISABLE_MOVE = "move";
	public static final String ID_DISABLE_RESIZE = "resize";
	public static final String ID_DISABLE_RECONNECT = "reconnect";
	public static final String ID_DISABLE_SELECT = "select";
	public static Set<String> DISABLE_NODE_VALUES = new HashSet<String>(Arrays.asList("create", "delete", "move", "resize", "select"));
	public static Set<String> DISABLE_EDGE_VALUES = new HashSet<String>(Arrays.asList("create", "delete", "reconnect", "select"));
	
	
	public static boolean isCreateDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_CREATE);
	}
	
	public static boolean isMoveDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_MOVE);
	}
	
	public static boolean isResizeDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_RESIZE);
	}
	
	public static boolean isSelectDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_SELECT);
	}
	
	public static boolean isReconnectDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_RECONNECT);
	}
	
	public static boolean isDeleteDisabled(ModelElement me) {
		return isDisabled(me, ID_DISABLE_DELETE);
	}
	
	public static boolean isDisabled(ModelElement me, String id) {
		for (Annotation annot : me.getAnnotations()) {
			if (annot.getName().equals(ID_DISABLE)) {
				return (annot.getValue().isEmpty() || annot.getValue().contains(id));
			}
		}
		return false;
	}
	
	public static boolean isAttributeReadOnly(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("readOnly"))
				return true;
		}
		return false;
	}
	
	public static Resource getStylesResource(String pathToStyles, IProject p) {
		Resource res = null;
		URI uri = URI.createURI(pathToStyles, true);
		try {
			res = null;
			if (uri.isPlatformResource())
				res = new ResourceSetImpl().getResource(uri, true);
			else {
				IFile file = p.getFile(pathToStyles);
				URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
				res = new ResourceSetImpl().getResource(fileURI, true);
			}
			return res;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	
	
	public static Styles getStyles(GraphModel gm) {
		for (Annotation a : gm.getAnnotations()) {
			if (ID_STYLE.equals(a.getName())) {
				String path = a.getValue().get(0);
				URI uri = URI.createURI(path, true);
				try {
					Resource res = null;
					if (uri.isPlatformResource()) {
						res = new ResourceSetImpl().getResource(uri, true);
					}
					else {
						IProject p = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(gm.eResource().getURI().toPlatformString(true))).getProject();
						IFile file = p.getFile(path);
						if (file.exists()) {
							URI fileURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
							res = new ResourceSetImpl().getResource(fileURI, true);
						}
						else {
							return null;
						}
					}
					
					for (Object o : res.getContents()) {
						if (o instanceof Styles)
							return (Styles) o;
					}
				} catch (Exception e) {
					e.printStackTrace();
					return null;
				}
			}
		}
		return null;
	}
	
	public static Style findStyle(Styles styles, String name) {
		if (styles == null)
			return null;
		for (Style s : styles.getStyles()) {
			if (name.equals(s.getName()))
				return s;
		}
		return null;
	}



	public static GraphModel getGraphModel(Resource res) {
		for (TreeIterator<EObject> it = res.getAllContents(); it.hasNext(); ) {
			EObject o = it.next();
			if (o instanceof GraphModel)
				return (GraphModel) o; 
		}
		return null;
		
	}

	public static boolean isAttributeMultiValued(Attribute attr) {
		return attr.getUpperBound() != 1;
	}
	
	public static boolean isAttributeMultiLine(Attribute attr) {
		for (Annotation annot : attr.getAnnotations()) {
			if (annot.getName().equals("multiLine"))
				return true;
		}
		return false;
	}
	
	public static void refreshFiles(IProgressMonitor monitor, IFile...files) {
		for (IFile f : files)
			try {
				f.refreshLocal(IResource.DEPTH_ZERO, monitor);
			} catch (CoreException e) {
				System.err.println("Refresh folder error...");
				e.printStackTrace();
			}
	}
	
	public static void refreshFolders(IProgressMonitor monitor, IFolder...folders) {
		for (IFolder f : folders)
			try {
				f.refreshLocal(IResource.DEPTH_ONE, monitor);
			} catch (CoreException e) {
				System.err.println("Refresh folder error...");
				e.printStackTrace();
			}
	}

	public static List<String> getUsedExtensions(GraphModel gModel) {
		List<String> extensions = new ArrayList<>();
		for (Import i : gModel.getImports()) {
			if (i.getImportURI().endsWith(".mgl")) {
				GraphModel gm = getImportedGraphModel(i);
				extensions.add(gm.getFileExtension());
			}
			if (i.getImportURI().endsWith(".ecore")) {
				GenModel gm = getImportedGenmodel(i);
				extensions.add(getFileExtension(gm));
			}
		}
		return extensions;
	}

	private static GenModel getImportedGenmodel(Import i) {
		URI genModelURI = URI.createURI(i.getImportURI().replace(".ecore", ".genmodel"));
		Resource res = new ResourceSetImpl().getResource(genModelURI, true);
		if (res != null)
			try {
				res.load(null);
				EObject genModel = res.getContents().get(0);
				if (genModel instanceof GenModel)
					return (GenModel) genModel;
			} catch (IOException e) {
				e.printStackTrace();
			}
		return null;
	}

	private static GraphModel getImportedGraphModel(Import i) {
		URI gmURI = URI.createURI(i.getImportURI(), true);
		Resource res = new ResourceSetImpl().getResource(gmURI, true);
		EObject graphModel = res.getContents().get(0);
		if (graphModel instanceof GraphModel)
			return (GraphModel) graphModel;
		return null;
	}
	
	private static String getFileExtension(GenModel genModel) {
		for (GenPackage gp : genModel.getAllGenPackagesWithClassifiers()) {
			return gp.getFileExtension();
		}
		
		return "";
	}
}
