package de.jabc.cinco.meta.core.ge.style.model.validator;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;

public class StylesValidator {

	public static String checkImagePath(EObject o, String path) {
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		URI iconURI = URI.createURI(path, true);
		URI resURI = o.eResource().getURI();
		
	/** Not an platform URI, following check if iconURI is a valid project-relative path **/
		if (!iconURI.isPlatformResource()) {
			/** Get the current project **/
			IProject p = root.getFile(new Path(resURI.toPlatformString(true))).getProject();
			IFile file = p.getFile(path);
			if (!file.exists()) {
				return "The specified icon file: \""+path+"\" does not exists.";
			}
		} 
		/** iconURI is platform URI. Search the IResource **/
		else {
			IResource res = root.findMember(iconURI.toPlatformString(true));
			if (res == null || !(res instanceof IFile) ) {
				return "The specified icon file: \""+path+"\" does not exists.";
			}
		}
		
		return "";
	}
	
}
