package de.jabc.cinco.meta.core.referenceregistry;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IActionDelegate;

public class ClearReferenceRegistryAction implements IActionDelegate {


	@Override
	public void run(IAction action) {
		ReferenceRegistry.getInstance().clearRegistry();
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		// do nothing
	}


}
