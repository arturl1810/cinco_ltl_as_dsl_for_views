package de.jabc.cinco.meta.plugin.pyro.utils;

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
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/testapp-business"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/testapp-presentation"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/testapp-preconfig"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/testapp-persistence"), new File(target));
			FileUtils.copyFileToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/pom.xml"), new File(target));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
