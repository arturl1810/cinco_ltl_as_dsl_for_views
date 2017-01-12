package de.jabc.cinco.meta.plugin.gratext.runtime.util;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.ui.IEditorInput;


public class GratextUtils {
	
	
	public static SafeRunnable task(String name) {
		return (runnable) -> {
			SafeRunner.run(new ISafeRunnable() {
				
				@Override
				public void handleException(Throwable e) {
					System.err.println("Failed to run '" + name + "': " + e.getMessage());
				}

				@Override
				public void run() throws Exception {
					System.out.println("Run '" + name + "'");
					runnable.run();
				}
			});
	    };
	}
	
	@FunctionalInterface
	public static interface SafeRunnable {
		public void run(Runnable runnable);
	}
	
	/**
	 * Extracts the file URI if the specified input references a file.
	 */
	public static URI getUri(IEditorInput input) {
		URI uri = null;
		if (input instanceof IAdaptable) {
			IFile file = (IFile) ((IAdaptable) input).getAdapter(IFile.class);
			if (file != null) {
				String pathName = file.getFullPath().toString();
				uri = URI.createPlatformResourceURI(pathName, true);
				uri = new ResourceSetImpl().getURIConverter().normalize(uri);
			}
		}
		return uri;
	}
}
