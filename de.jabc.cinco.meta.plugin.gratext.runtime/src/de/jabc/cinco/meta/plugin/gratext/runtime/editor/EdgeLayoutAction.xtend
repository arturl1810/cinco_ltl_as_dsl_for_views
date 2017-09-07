package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.gef.ui.actions.SelectionAction
import org.eclipse.ui.IWorkbenchPart

class EdgeLayoutAction extends SelectionAction {
	
	final EdgeLayoutMode mode
	
	new(IWorkbenchPart part, EdgeLayoutMode mode) {
		super(part)
		this.mode = mode
	}
	
	override getId() {
		mode.id
	}
	
	override protected calculateEnabled() {
		System.err.println("[EdgeLayoutAction] calculateEnabled");
		
		false
	}
	
}