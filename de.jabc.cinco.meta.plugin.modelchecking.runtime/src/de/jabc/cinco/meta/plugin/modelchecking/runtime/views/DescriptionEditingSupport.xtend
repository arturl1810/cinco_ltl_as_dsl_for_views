package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import org.eclipse.jface.viewers.CellEditor
import org.eclipse.jface.viewers.TextCellEditor
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula

class DescriptionEditingSupport extends ModelCheckingEditingSupport {
	
	final CellEditor editor

	new(ModelCheckingView view) {
		super(view)
		this.editor = new TextCellEditor(view.viewer.table)
	}

	override protected getCellEditor(Object element) {
		editor
	}

	override protected getValue(Object element) {
		(element as CheckFormula).description
	}

	override protected setValue(Object element, Object value) {
		if ((value as String) != "") {
			var newDescription = (value as String)
			var formula = (element as CheckFormula)
			if (handler !== null && !newDescription.equals(formula.description)) {
				handler.setDescription(formula, newDescription)
				view.refreshAll
			}
		}
	}
}
