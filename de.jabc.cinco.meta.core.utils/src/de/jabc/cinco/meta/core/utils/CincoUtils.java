package de.jabc.cinco.meta.core.utils;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;


public class CincoUtils {

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
	
}
