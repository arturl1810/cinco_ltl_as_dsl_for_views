package de.jabc.cinco.meta.core.referenceregistry;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IActionDelegate;

public class ClearRefReg implements IActionDelegate {

	public ClearRefReg() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public void run(IAction action) {
		ReferenceRegistry.getInstance().clearRegistry();
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		// TODO Auto-generated method stub
		
	}

}
