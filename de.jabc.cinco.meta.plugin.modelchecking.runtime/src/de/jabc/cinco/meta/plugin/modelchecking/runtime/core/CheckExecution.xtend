package de.jabc.cinco.meta.plugin.modelchecking.runtime.core

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import java.util.List
import static de.jabc.cinco.meta.core.utils.job.JobFactory.job
import java.util.Set
import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.CheckFormula
import de.jabc.cinco.meta.plugin.modelchecking.runtime.util.ModelCheckingRuntimeExtension

import graphmodel.GraphModel
import graphmodel.Node
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.ModelChecker
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel

class CheckExecution {
	
	extension WorkbenchExtension = new WorkbenchExtension
	extension ModelCheckingRuntimeExtension = new ModelCheckingRuntimeExtension
	
	var Set<CheckExecutionListener> listeners = newHashSet
	
	new(){}
	
	def <N,E> executeFormulasCheck(ModelCheckingAdapter adapter, ModelChecker<CheckableModel<N,E>,N,E> checker, GraphModel model, List<CheckFormula> formulas, boolean withSelection){
		if (checker === null) throw new RuntimeException("No ModelChecker set.")
		val checkableModel = adapter.getCheckableModel(checker, withSelection)
		if (formulas.size == 0){
			notifyCheckFinished
			return
		}
		job("Check Formulas")
			.consumeConcurrent(100)
			.taskForEach(formulas,[checker.checkAndInform(model, checkableModel, it)],[getJobName])
			.onDone[notifyCheckFinished]
			.schedule
	}
	
	private def <N,E> getCheckableModel(ModelCheckingAdapter adapter, ModelChecker<CheckableModel<N,E>,N,E> checker, boolean withSelection){
		val checkableModel = checker.createCheckableModel
		adapter.buildCheckableModel(checkableModel, withSelection)
		checkableModel
	}
 	
 	def <N,E> getSatisfyingNodes(ModelChecker<CheckableModel<N,E>,N,E> checker, GraphModel model, CheckableModel<N,E> checkableModel, String expression) throws Exception{	
		val satisfyingNodeIds = checker.getSatisfyingNodes(checkableModel, expression).map[checkableModel.getId(it)].toSet
		model.allNodes.filter[satisfyingNodeIds.contains(it.id)].toSet		
	}
	
	def <N,E> checkAndInform(ModelChecker<CheckableModel<N,E>,N,E> checker, GraphModel model, CheckableModel<N,E> checkableModel, CheckFormula formula){
		if (formula.toCheck){
			try{
				var satisfyingNodes = checker.getSatisfyingNodes(model, checkableModel, formula.expression)
				formula.satisfyingNodes = satisfyingNodes
				formula.result = model.getFormulaCheckResult(checkableModel, satisfyingNodes)
				
			}catch(Exception e){
				formula.resetCheckResult
				formula.result = Result.ERROR
				formula.errorMessage = e.message
				//e.printStackTrace
			}
		}else{
			formula.resetCheckResult
		}
		notifyNewResult(formula) 			
	}
	
	def getFormulaCheckResult(GraphModel model, CheckableModel<?,?> checkableModel, Set<Node> satisfying){
		if (model.fulfills(checkableModel,satisfying)){
			return Result.TRUE
		}
		Result.FALSE
	}
	
	def fulfills(GraphModel model, CheckableModel<?,?> checkableModel, Set<Node> satisfying){
		val adapter = model.adapter
		if (adapter === null) throw new RuntimeException("No suitable adapter found.")
		model.adapter.fulfills(model, checkableModel,satisfying)
	}
	
	def getJobName(CheckFormula formel){
		if (formel.description.equals("")){
			return "Checking " + formel.expression
		}
		else {
			return "Checking " + formel.description
		}
	}	
	
	//Listener methods
	
	interface CheckExecutionListener {
		def void onNewResult(CheckFormula formula)
		def void onFinished()
	}
	
	def addCheckExecutionListener(CheckExecutionListener listener){
		listeners.add(listener)
	}
	
	def removeCheckExecutionListener(CheckExecutionListener listener){
		listeners.remove(listener)
	}
	
	def notifyNewResult(CheckFormula formula){
		async[listeners.forEach[
			onNewResult(formula)
		]]
	}
	
	def notifyCheckFinished(){
		async[listeners.forEach[onFinished]]
	}	
}