package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import org.eclipse.jface.viewers.EditingSupport
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaHandler

abstract class ModelCheckingEditingSupport extends EditingSupport {
	
	protected val ModelCheckingView view
	protected FormulaHandler<?, ?> handler

	new(ModelCheckingView view) {
		super(view.viewer)
		this.view = view
	}

	def setFormulaHandler(FormulaHandler<?, ?> handler) {
		this.handler = handler
	}

	override protected canEdit(Object element) {
		true
	}
}
