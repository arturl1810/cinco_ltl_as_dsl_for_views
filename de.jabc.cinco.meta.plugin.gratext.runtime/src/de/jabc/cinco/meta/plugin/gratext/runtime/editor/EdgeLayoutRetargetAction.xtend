package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.ui.actions.LabelRetargetAction

class EdgeLayoutRetargetAction extends LabelRetargetAction {
	
	new(EdgeLayoutMode mode) {
		super(mode.id, mode.text)
		toolTipText = mode.text
		imageDescriptor = mode.imageDescriptor
		disabledImageDescriptor = mode.disabledImageDescriptor
	}
	
	public static def create(EdgeLayoutMode mode) {
		new EdgeLayoutRetargetAction(mode)
	}
	
}