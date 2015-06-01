package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;


public class FileHandler {
	public static void copyResources(String bundleId, String target) {
		Bundle b = Platform.getBundle(bundleId);
		try {
			File source = FileLocator.getBundleFile(b);
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resources/papyrus/"), new File(target));
			
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
