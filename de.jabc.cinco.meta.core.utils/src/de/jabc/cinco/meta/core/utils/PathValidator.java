package de.jabc.cinco.meta.core.utils;

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
			return checkFileExists(getFile(path));
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
			IFile file = getFile(path);
			if (file.exists())
				return getURI(file);
		}
		return null;
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
	
	private static String checkFileExists(IFile file) {
        if (!file.exists()) {
			return "The specified file: \""+file.getFullPath()+"\" does not exist.";
		}
		return "";
	}
	
	private static URI getURI(IFile file) {
        if (!file.exists()) 
			return null;
		return URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true);
	}
	
	private static IFile getFile(String path) {
        if (path == null || path.isEmpty())
        	return null;
        IFile resFile = null;
        if (res.getURI().isPlatform()) {
        	resFile = root.getFile(new Path(res.getURI().toPlatformString(true)));
        } else {
        	resFile = root.getFileForLocation(Path.fromOSString(res.getURI().path()));
        }
        URI uri = URI.createURI(path);
        if (uri.isPlatform())
        	return root.getFile(new Path(uri.toPlatformString(true)));
        else
        	return resFile.getProject().getFile(path);
	}
}
