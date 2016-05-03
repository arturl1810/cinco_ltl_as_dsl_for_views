package de.jabc.cinco.meta.plugin.gratext.util;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;


public class GratextUtils {

	
	
	/**
	 * Convenient method to wrap a modification of an EObject in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param obj  The object for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	public static Edit edit(EObject obj) {
		return edit(obj.eResource());
	}
	
	/**
	 * Convenient method to wrap a modification of a Resource in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param res  The resource for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	public static Edit edit(Resource res) {
		return (runnable) -> {
			TransactionalEditingDomain domain = TransactionUtil.getEditingDomain(res);
			if (domain == null) {
				domain = TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(res.getResourceSet());
			}
			domain.getCommandStack().execute(new RecordingCommand(domain) {
				@Override protected void doExecute() {
					try {
						runnable.run();
					} catch(IllegalStateException e) {
						e.printStackTrace();
					}
				}
			});
	    };
	}
	
	@FunctionalInterface
	public static interface Edit {
		public void transact(Runnable runnable);
	}
	
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
	
	public static void async(Runnable runnable) {
		Display display = Display.getCurrent();
		if (display == null)
			display = Display.getDefault();
		display.asyncExec(runnable);
	}
	
	public static void sync(Runnable runnable) {
		Display display = Display.getCurrent();
		if (display == null)
			display = Display.getDefault();
		display.syncExec(runnable);
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
