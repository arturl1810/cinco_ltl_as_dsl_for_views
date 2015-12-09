package de.jabc.cinco.meta.core.referenceregistry;

import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IActionDelegate;

public class ReInitializeFromWorkspace implements IActionDelegate {


	@Override
	public void run(IAction action) {
		ReferenceRegistry.getInstance().reinitialize(ResourcesPlugin.getWorkspace().getRoot());
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		
	}


}
