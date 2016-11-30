package de.jabc.cinco.meta.core.utils;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public class PathValidator {

	private static IWorkspaceRoot root;
	private static Resource res;
	
	public static synchronized boolean isRelativePath(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI uri = URI.createURI(path, true);
		
		if (uri.isPlatformResource() || uri.isPlatformPlugin()) {
			return false;
		} else return true;
	}
	
	public static synchronized String checkPath(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI uri = URI.createURI(path, true);
		
		if (uri.isPlatformResource()) {
			return checkPlatformResourceURI(uri);
		}
		
		else if (uri.isPlatformPlugin()) {
			return checkPlatformPluginURI(uri);
		}
		
		else {
			return checkRelativePath(res.getURI(), path);
		}
	}

	public static synchronized URI getURIForString(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI uri = URI.createURI(path, true);
		String retval = null;
		
		if (uri.isPlatformResource()) {
			retval = checkPlatformPluginURI(uri);
			if (retval == null || retval.isEmpty())
				return uri;
		}
		
		else if (uri.isPlatformPlugin()) {
			retval = checkPlatformPluginURI(uri);
			if (retval == null || retval.isEmpty()) 
				return uri;
		}
		
		else {
			retval = checkRelativePath(res.getURI(), path);
			if (retval == null || retval.isEmpty()) {
				return pathToURI(res.getURI(), path);
			}
				
		}
		return null;
	}

	public static synchronized URL getURLForString(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI uri = URI.createURI(path, true);
		String retval = null;
		
		try {
			if (uri.isPlatformResource()) {
				retval = checkPlatformPluginURI(uri);
				if (retval == null || retval.isEmpty()){
					IResource member = root.findMember(uri.toPlatformString(true));
						return member.getLocationURI().toURL();
				}
			}
			
			else if (uri.isPlatformPlugin()) {
				retval = checkPlatformPluginURI(uri);
				if (retval == null || retval.isEmpty()) {
					IResource res = root.findMember(uri.toPlatformString(true));
					return res.getLocationURI().toURL();
				}
			}
			
			else {
				retval = checkRelativePath(res.getURI(), path);
				if (retval == null || retval.isEmpty()) {
					return pathToURL(res.getURI(), path);
				}
					
			}
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public static String getBundleID(URI uri) {
		URI trimmed = null;
		if (uri.isPlatformPlugin() || uri.isPlatformResource()) {
			trimmed = URI.createURI(uri.toPlatformString(true));
		}
		if (uri.isRelative()) {
			trimmed = uri;
		}
		if (uri.isPlatform()){
			trimmed = uri.deresolve(URI.createURI("platform:/"));
		}
		if (trimmed != null)
			return trimmed.segment(0);
		throw new RuntimeException("The uri: \"" + uri +"\" could not be recognized");
	}
	
	private static String checkPlatformResourceURI(URI uri) {
		IResource res = root.findMember(uri.toPlatformString(true));
		if (res == null || !(res instanceof IFile) ) {
			return "The specified file does not exists.";
		}
		return "";
	}
	
	private static String checkPlatformPluginURI(URI uri) {
		IResource res = root.findMember(uri.toPlatformString(true));
		if (res == null || !(res instanceof IFile) ) {
			return "The specified file does not exists.";
		}
		return "";
	}
	
	private static String checkRelativePath(URI resUri, String path) {
        if (path != null && path.isEmpty())
                return "No path specified";
        IProject p = root.getFile(new Path(res.getURI().toPlatformString(true))).getProject();
        IFile file = p.getFile(path);
		if (!file.exists()) {
			return "The specified file: \""+path+"\" does not exists.";
		}
		return "";
	}
	
	private static URI pathToURI(URI resURI, String path) {
        if (path != null && path.isEmpty())
        	return null;
        IProject p = root.getFile(new Path(res.getURI().toPlatformString(true))).getProject();
        IFile file = p.getFile(path);
		if (!file.exists()) 
			return null;
		return URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true);
	}
	
	private static URL pathToURL(URI resURI, String path) {
        if (path != null && path.isEmpty())
        	return null;
        IProject p = root.getFile(new Path(res.getURI().toPlatformString(true))).getProject();
        IFile file = p.getFile(path);
		if (!file.exists()) 
			return null;
		try {
			return file.getLocationURI().toURL();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
		return null;
	}
	
}
