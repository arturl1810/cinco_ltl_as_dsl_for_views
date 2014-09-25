package de.jabc.cinco.meta.core.ui;

import org.eclipse.ui.IStartup;
import org.eclipse.ui.IWindowListener;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;

public class Startup implements IStartup {

	@Override
	public void earlyStartup() {
		final MGLSelectionListener selectionListener = MGLSelectionListener.INSTANCE;
		IWorkbench workbench = PlatformUI.getWorkbench();
		workbench.addWindowListener(new IWindowListener() {
			@Override
			public void windowOpened(IWorkbenchWindow window) {
				window.getSelectionService().addSelectionListener(selectionListener);
			}
			@Override
			public void windowDeactivated(IWorkbenchWindow window) { }
			@Override
			public void windowClosed(IWorkbenchWindow window) { }
			@Override
			public void windowActivated(IWorkbenchWindow window) { }
		});
		for (IWorkbenchWindow window : workbench.getWorkbenchWindows()) {
			window.getSelectionService().addSelectionListener(selectionListener);
		}
	}
}
