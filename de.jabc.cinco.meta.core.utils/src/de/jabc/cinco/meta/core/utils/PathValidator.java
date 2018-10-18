package de.jabc.cinco.meta.core.utils;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
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
			String fileExists = checkFileExists(getFile(path));
			if(!fileExists.isEmpty()) {
				//check for folder
				String folderExists = checkFolderExists(getFolder(path));
				if(!folderExists.isEmpty()) {
					return fileExists+folderExists;
				}
				return folderExists;
			}
			return fileExists;
		}
	}

	public static synchronized URI getURIForString(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI uri = URI.createURI(path, true);
		String retval = null;
		
		if (uri.isPlatformResource()) {
			retval = checkPlatformResourceURI(uri);
			if (retval == null || retval.isEmpty())
				return uri;
		}
		
		if (uri.isPlatformPlugin()) {
			retval = checkPlatformPluginURI(uri);
			if (retval == null || retval.isEmpty())
				return uri;
		}
		
		else {
			IResource resource = getFile(path);
			if(!resource.exists()) {
				//try folder
				resource = getFolder(path);
			}
			if (resource.exists())
				return getURI(resource);
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
				retval = checkPlatformResourceURI(uri);
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
				retval = checkRelativePath(path);
				if (retval == null || retval.isEmpty()) {
					return pathToURL(res.getURI(), path);
				}
					
			}
		} catch (MalformedURLException e) {
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
		try {
			URL find = FileLocator.find(new URL(uri.toString()));
			URL fileUrl = FileLocator.toFileURL(find);
			File file = new File(fileUrl.getFile());
			if (!file.exists())
				return "The specified plugin files does not exist";
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}
	
	private static String checkRelativePath(String path) {
        if (path != null && path.isEmpty())
                return "No path specified";
        IProject p;
        IFile file;
        URI uri = res.getURI();
		if (uri.isFile()) {
			IPath fromOSString = Path.fromOSString(uri.toFileString());
        	IResource member = root.getFileForLocation(fromOSString);
        	if (member != null) {
        		p = member.getProject();
        		file = p.getFile(path);
        		if (!file.exists()) {
        			return "The specified file: \""+path+"\" does not exists.";
        		}
        	}
        		
        } else {
	        file = handlePlatformUri(path, uri);
			if (!file.exists()) {
				return "The specified file: \""+path+"\" does not exists.";
			}
        }
		return "";
	}
	
	private static URI pathToURI(String path) {
        if (path != null && path.isEmpty())
        	return null;
        URI uri = res.getURI();
        IFile file = null;
		if (uri.isFile())
			file = handleFileUri(path, uri);
		else file = handlePlatformUri(path, uri);
		if (!file.exists()) 
			return null;
		return URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true);
	}
	private static String checkFileExists(IFile file) {
        if (!file.exists()) {
			return "The specified file: \""+file.getFullPath()+"\" does not exist.";
		}
		return "";
	}
	
	private static String checkFolderExists(IFolder folder) {
        if (!folder.exists()) {
			return "The specified folder: \""+folder.getFullPath()+"\" does not exist.";
		}
		return "";
	}
	
	private static URI getURI(IResource file) {
        if (!file.exists()) 
			return null;
		return URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true);
	}
	
	private static URL pathToURL(URI resURI, String path) {
        if (path != null && path.isEmpty())
        	return null;
        IFile file = null;
        URI uri = res.getURI();
		if (uri.isFile()) {
        	file = handleFileUri(path, uri);
        } else {
        	file = handlePlatformUri(path, uri);
		if (!file.exists()) 
			return null;
        }
		try {
			return file.getLocationURI().toURL();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
		return null;
	}

	private static IFile handlePlatformUri(String path, URI uri) {
		IProject p;
		IFile file;
		p = root.getFile(new Path(uri.toPlatformString(true))).getProject();
		file = p.getFile(path);
		return file;
	}

	private static IFile handleFileUri(String path, URI uri) {
		IProject p;
		IFile file = null;
		IPath fromOSString = Path.fromOSString(uri.toFileString());
		IResource member = root.getFileForLocation(fromOSString);
		if (member != null) {
			p = member.getProject();
			file = p.getFile(path);
			if (!file.exists()) {
				return null;
			}
		}
		return file;
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
	
	private static IFolder getFolder(String path) {
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
        	return root.getFolder(new Path(uri.toPlatformString(true)));
        else
        	return resFile.getProject().getFolder(path);
	}
}
