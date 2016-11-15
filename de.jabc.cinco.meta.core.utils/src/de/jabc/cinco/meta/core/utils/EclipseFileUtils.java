package de.jabc.cinco.meta.core.utils;

import java.io.File;
import java.net.URL;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.internal.resources.ResourceException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.CommonPlugin;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.util.StringInputStream;
import org.osgi.framework.Bundle;

public class EclipseFileUtils {

	public static void mkdirs(IFolder folder, IProgressMonitor monitor) throws CoreException {
	    if (!folder.exists()) {
		    if (folder.getParent() instanceof IFolder) {
		    	mkdirs((IFolder) folder.getParent(), monitor);
		    }
		    try {
		    	folder.create(true, true, null);
	        }
		    catch (ResourceException re) {
		    	// TODO: This is ugly. Needs to be beautified soon[tm]
		    	if (!re.getMessage().startsWith("A resource already exists on disk")) {
		    		throw re;
		    	}
		    	else System.out.println(re);
		    }

	    }
	}
	
	public static void writeToFile(IFile file, CharSequence contents) {
		try {
			if(!file.exists()) {
				file.create(new StringInputStream(contents.toString()), true, null);
			}
			else {
				file.setContents(new StringInputStream(contents.toString()), true, true, null);
			}
		}
		catch (CoreException e) {
			throw new RuntimeException(e);
		}
	}
	
	
	public static File getFileForModel(EObject model) {
		// get file for model (eObject)
		org.eclipse.emf.common.util.URI resolvedFile = CommonPlugin.resolve(EcoreUtil.getURI(model));
		IFile iFile = ResourcesPlugin.getWorkspace().getRoot()
				.getFile(new Path(resolvedFile.toFileString()));

		File file = iFile.getFullPath().toFile();
		if (file == null)
			throw new RuntimeException("Could not find file for " + model);
		if (!file.exists())
			throw new RuntimeException("File does not exist for " + model);

		return file;
	}
	
	/**
	 * Helper method for code generators that require static files given in some bundle (probably the one
	 * where the code generator is implemented).
	 * 
	 * If pathInBundle is a file, it will be copied to targetDirectory. If it is a directory, all its contents 
	 * will be copied to targetDirectory.
	 * 
	 * @param bundleId
	 * @param pathInBundle
	 * @param targetDirectory
	 */
	public static void copyFromBundleToDirectory(String bundleId, String pathInBundle, IFolder targetDirectory) {
		Bundle b = Platform.getBundle(bundleId);
		URL directoryURL = b.getEntry(pathInBundle);
		if (directoryURL == null) {
			throw new RuntimeException(String.format("path '%s' not found in bundle '%s'", pathInBundle, bundleId));
		}
		try {
			// solution based on http://stackoverflow.com/a/23953081
			URL fileURL = FileLocator.toFileURL(directoryURL);
			java.net.URI resolvedURI = new java.net.URI(fileURL.getProtocol(), fileURL.getPath(), null);
		    File sourceFile = new File(resolvedURI);
		    File targetDir = targetDirectory.getRawLocation().makeAbsolute().toFile(); 
		    if (sourceFile.isDirectory()) {
		    	FileUtils.copyDirectoryToDirectory(sourceFile, targetDir);
		    }
		    else {
		    	FileUtils.copyFileToDirectory(sourceFile, targetDir);
		    }
		}
		catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	
	/**
	 * Helper method for code generators that require static files given in some bundle (probably the one
	 * where the code generator is implemented).
	 * 
	 * @param bundleId
	 * @param pathInBundle
	 * @param targetFile
	 */
	public static void copyFromBundleToFile(String bundleId, String pathInBundle, IFile targetFile) {
		Bundle b = Platform.getBundle(bundleId);
		URL directoryURL = b.getEntry(pathInBundle);
		if (directoryURL == null) {
			throw new RuntimeException(String.format("path '%s' not found in bundle '%s'", pathInBundle, bundleId));
		}
		try {
			// solution based on http://stackoverflow.com/a/23953081
			URL fileURL = FileLocator.toFileURL(directoryURL);
			java.net.URI resolvedURI = new java.net.URI(fileURL.getProtocol(), fileURL.getPath(), null);
		    File source = new File(resolvedURI);
		    File target = targetFile.getRawLocation().makeAbsolute().toFile(); 
		    FileUtils.copyFile(source, target);
		}
		catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	
	
	
	
}
