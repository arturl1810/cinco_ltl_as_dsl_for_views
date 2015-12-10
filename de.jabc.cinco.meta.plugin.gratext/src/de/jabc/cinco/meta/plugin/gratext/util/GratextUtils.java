package de.jabc.cinco.meta.plugin.gratext.util;

import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Launcher;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;

import de.jabc.cinco.meta.plugin.gratext.descriptor.FileDescriptor;
import de.jabc.cinco.meta.plugin.gratext.template.GratextMWETemplate;


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
		return (runnable) -> {
			TransactionalEditingDomain domain = TransactionUtil.getEditingDomain(obj);
			if (domain == null)
				domain = TransactionalEditingDomain.Factory.INSTANCE
					.createEditingDomain(obj.eResource().getResourceSet());
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
		public void apply(Runnable runnable);
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
}
