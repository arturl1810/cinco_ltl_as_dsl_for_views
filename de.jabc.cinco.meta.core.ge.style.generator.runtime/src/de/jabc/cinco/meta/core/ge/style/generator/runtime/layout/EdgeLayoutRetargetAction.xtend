package de.jabc.cinco.meta.core.ge.style.generator.runtime.layout

import org.eclipse.ui.actions.LabelRetargetAction

class EdgeLayoutRetargetAction extends LabelRetargetAction {
	
	new(EdgeLayout mode) {
		super(mode.id, mode.text)
		toolTipText = mode.text
		imageDescriptor = mode.imageDescriptor
		disabledImageDescriptor = mode.disabledImageDescriptor
	}
}
