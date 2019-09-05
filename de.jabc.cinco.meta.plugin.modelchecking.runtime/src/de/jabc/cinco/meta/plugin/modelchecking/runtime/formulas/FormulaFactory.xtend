package de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas

import java.util.List
import graphmodel.GraphModel
import graphmodel.Type

interface FormulaFactory<M extends GraphModel, T extends Type> {
	
	def abstract List<CheckFormula> createFormulas(M model)

	def abstract CheckFormula createFormula(T formula)

	def abstract T createGraphModelFormula(String exp)

}
