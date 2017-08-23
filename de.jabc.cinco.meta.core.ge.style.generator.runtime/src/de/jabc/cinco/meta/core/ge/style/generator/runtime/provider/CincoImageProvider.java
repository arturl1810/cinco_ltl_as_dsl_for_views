package de.jabc.cinco.meta.core.ge.style.generator.runtime.provider;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Enumeration;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.impl.FileURIHandlerImpl;
import org.eclipse.graphiti.ui.platform.AbstractImageProvider;
import org.eclipse.graphiti.ui.platform.IImageProvider;
import org.osgi.framework.Bundle;

public class CincoImageProvider extends AbstractImageProvider implements IImageProvider {

	private static CincoImageProvider cip;
	
	/**
	 * This class is instantiated by Graphiti. It should not be used by clients. 
	 * To retrieve the image provider use method {@link CincoImageProvider.getImageProvider}
	 */
	public CincoImageProvider() {
		cip = this;
		Class<CincoImageProvider> theClass = CincoImageProvider.class;
		Constructor<CincoImageProvider> constructor;
		try {
			constructor = theClass.getConstructor();
			constructor.setAccessible(false);
//			System.out.println("Making constructor");
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static CincoImageProvider getImageProvider() {
		return cip;
	}
	
	
	/** Registers an image for the Graphiti editor context.
	 * @param id The id to reference the image
	 * @param fileURL URL of the file image represented as String
	 */
	public void registerImage(String id, String fileURL) {
		addImageFilePath(id, fileURL);
	}
	
	@Override
	protected void addAvailableImages() {
	}
	
	public void initImagesForBundle(String bundleID)  {
		Bundle b = Platform.getBundle(bundleID);
		File file;
		try {
			file = FileLocator.getBundleFile(b);
			File genIconsFile = file.toPath().resolve("resources-gen/icons").toFile();
			if (genIconsFile.exists()) {
				for (File f : genIconsFile.listFiles()){
					String fileName = f.getName();
					addImageFilePath(fileName, f.toURI().toURL().toString());
				}
			}
			if (!genIconsFile.exists() ) {
				Enumeration<URL> entries = b.findEntries("resources-gen/icons/", "*", true);
				while(entries.hasMoreElements()){
					URL entry = entries.nextElement();
					IPath path = new Path(entry.getPath());
					File i = path.toFile();
					String fileName = i.getName();
					String id = fileName;
					addImageFilePath(id, entry.toString());
				}
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
