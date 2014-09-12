package de.jabc.cinco.meta.core.utils;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.ui.PlatformUI;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.common.services.Ecore2XtextTerminalConverters;

public class PathValidator {

	private static IWorkspaceRoot root;
	private static Resource res;
	
	public static synchronized String checkPath(EObject o, String path) {
		root = ResourcesPlugin.getWorkspace().getRoot();
		res = o.eResource();
		URI iconURI = URI.createURI(path, true);
		
		if (iconURI.isPlatformResource()) {
			return checkPlatformResourceURI(iconURI);
		}
		
		else if (iconURI.isPlatformPlugin()) {
			return checkPlatformPluginURI(iconURI);
		}
		
		else {
			return checkRelativePath(res.getURI(), path);
		}
	}
	
	

	private static String checkPlatformResourceURI(URI uri) {
		IResource res = root.findMember(uri.toPlatformString(true));
		if (res == null || !(res instanceof IFile) ) {
			return "The specified file does not exists.";
		}
		return "";
	}
	
	private static String checkPlatformPluginURI(URI uri) {
		System.out.println(root.findMember(uri.toPlatformString(true)));
		System.err.println("PlatformPlugin uri, check not implemented yet.");
		return "";
	}
	
	private static String checkRelativePath(URI resUri, String path) {
		IProject p = root.getFile(new Path(res.getURI().toPlatformString(true))).getProject();
		IFile file = p.getFile(path);
		if (!file.exists()) {
			return "The specified file: \""+path+"\" does not exists.";
		}
		return "";
	}
}
