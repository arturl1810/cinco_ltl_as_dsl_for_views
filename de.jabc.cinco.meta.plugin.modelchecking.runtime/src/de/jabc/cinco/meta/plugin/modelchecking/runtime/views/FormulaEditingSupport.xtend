package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import java.util.Arrays
import org.eclipse.jface.viewers.CellEditor
import org.eclipse.jface.viewers.TextCellEditor
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula

class FormulaEditingSupport extends ModelCheckingEditingSupport {
	
	final CellEditor editor

	new(ModelCheckingView view) {
		super(view)
		this.editor = new TextCellEditor(view.viewer.table)
	}

	override protected getCellEditor(Object element) {
		editor
	}

	override protected getValue(Object element) {
		(element as CheckFormula).expression
	}
	
	override protected setValue(Object element, Object value) {
		if ((value as String) != "") {
			var newFormula = (value as String)
			var formula = (element as CheckFormula)
			if (handler !== null && !handler.contains(newFormula)) {
				handler.setExpression(formula, newFormula)
				view.refreshAll
				view.autoCheck(Arrays.asList(formula))
			}
		}
	}
}
