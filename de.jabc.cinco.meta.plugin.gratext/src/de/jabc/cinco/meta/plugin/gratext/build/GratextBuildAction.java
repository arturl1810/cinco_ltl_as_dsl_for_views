package de.jabc.cinco.meta.plugin.gratext.build;

import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IActionDelegate;

public class GratextBuildAction implements IActionDelegate {

	private ISelection selection;
	
	@Override
	public void run(IAction action) {
		GratextBuilder builder = new GratextBuilder();
		builder.setUser(true);
		builder.schedule();
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}

}
