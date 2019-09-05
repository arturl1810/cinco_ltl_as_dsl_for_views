package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import java.util.Arrays
import org.eclipse.jface.viewers.CellEditor
import org.eclipse.jface.viewers.CheckboxCellEditor
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula

class CheckEditingSupport extends ModelCheckingEditingSupport {
	
	val CellEditor editor

	new(ModelCheckingView view) {
		super(view)
		editor = new CheckboxCellEditor(view.viewer.table)
	}

	override protected getCellEditor(Object element) {
		editor
	}

	override protected getValue(Object element) {
		(element as CheckFormula).toCheck
	}

	override protected setValue(Object element, Object value) {
		if (handler !== null) {
			var newValue = (value as Boolean)
			var formula = (element as CheckFormula)
			if(formula.toCheck != newValue){
				handler.setToCheck(formula, newValue)
				view.refreshAll
				if (newValue) {
					view.autoCheck(Arrays.asList(formula))
				}
			}
		}
	}
}
