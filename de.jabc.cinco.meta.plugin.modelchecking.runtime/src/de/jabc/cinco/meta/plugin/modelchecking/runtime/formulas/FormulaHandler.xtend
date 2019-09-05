package de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas

import graphmodel.GraphModel
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import java.util.List
import graphmodel.Type
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaFactory
import org.eclipse.emf.common.util.EList
import java.util.function.Supplier
import java.util.function.Function

abstract class FormulaHandler<M extends GraphModel, T extends Type> {
	
	extension WorkbenchExtension = new WorkbenchExtension
	val FormulaFactory<M,T> formulaFactory;
	List<CheckFormula> formulas;
	volatile boolean editing;
	
	new(FormulaFactory<M,T> formulaFactory){
		this.formulaFactory = formulaFactory
		reloadFormulas();
		editing = false
	}
	
	def getModel(){
		activeGraphModel as M
	}
	
	def reloadFormulas(){
		val newFormulas = formulaFactory.createFormulas(model)
		if (formulas !== null){
			newFormulas.forEach[
				val formula = getFormulaById(it.id)
				if (formula !== null){
					it.result = formula.result
					it.errorMessage = formula.errorMessage
					it.satisfyingNodes = formula.satisfyingNodes
				}
			]
		}
		this.formulas = newFormulas
	}
	
	def getFormulas(){
		formulas
	}
	
	def hasToCheck(){
		return !formulas.filter[isToCheck].isEmpty
	}
	
	def getFormulaById(String id){
		formulas.findFirst[getId == id]
	}
	
	def getFormulaByExpression(String exp){
		formulas.findFirst[expression.equals(exp)]
	}
	
	def get(int index){
		formulas.get(index)
	}
	
	def getIndex(CheckFormula formula){
		formulas.indexOf(formula)
	}
	
	def getIndexById(String id){
		formulas.indexOf(id.formulaById)
	}
	
	def size(){
		formulas.size
	}
	
	def contains(String exp){
		formulas.map[getExpression].contains(exp)
	}
	
	def contains(CheckFormula formula){
		contains(formula.getExpression)
	}
	
	def add(String exp){
		val newFormula = formulaFactory.createGraphModelFormula(exp)
		edit[addFormulaToModel(newFormula)]
		formulas.add(formulaFactory.createFormula(newFormula))
	}
	
	def remove(CheckFormula formula){
		formulas.remove(formula)
		edit[removeFormulaFromModel(getFormulaFromModel(formula.getId))]
	}
	
	def setExpression(CheckFormula formula, String exp){
		formula.expression = exp
		edit[setExpression(getFormulaFromModel(formula.getId), exp)]
	}
	
	def setDescription(CheckFormula formula, String description){
		formula.description = description
		edit[setDescription(getFormulaFromModel(formula.getId), description)]
	}
	
	def setToCheck(CheckFormula formula, boolean toCheck){
		formula.toCheck = toCheck
		edit[setToCheck(getFormulaFromModel(formula.getId), toCheck)]
	}
	
	def getFormulaFromModel(String id){
		formulasFromModel.findFirst[it.id == id]
	}
	
	def edit(Runnable runnable){
		editing = true
		runnable.run
		editing = false
	}
	
	def isEditing(){
		editing
	}
	
	abstract def void addFormulaToModel(T formula)	
	//abstract def T getFormulaFromModel(String id)
	abstract def EList<T> getFormulasFromModel()
	abstract def void removeFormulaFromModel(T formula)
	abstract def void setExpression(T formula, String exp)
	abstract def void setDescription(T formula, String description)
	abstract def void setToCheck(T formula, boolean toCheck)
}
