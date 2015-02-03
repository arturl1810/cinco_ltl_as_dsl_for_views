package de.jabc.cinco.meta.core.utils;

import mgl.Annotation;
import mgl.GraphModel;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import style.Style;
import style.Styles;


public class CincoUtils {

	private static final String ID_STYLE = "style";
	
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
	
}
