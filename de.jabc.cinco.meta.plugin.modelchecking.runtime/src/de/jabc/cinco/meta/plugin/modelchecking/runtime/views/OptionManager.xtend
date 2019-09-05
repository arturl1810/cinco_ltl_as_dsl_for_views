package de.jabc.cinco.meta.plugin.modelchecking.runtime.views

import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.ModelChecker
import graphmodel.GraphModel
import java.util.Set

class OptionManager {
	val Set<Options> optionsSet
	var Options currentOptions
	val ModelChecker<?,?,?> defaultChecker
	
	new (ModelChecker<?,?,?> defaultChecker){
		optionsSet = newHashSet
		this.defaultChecker = defaultChecker
	}
	
	def void loadOptions(GraphModel model){
		currentOptions = optionsSet.findFirst[belongsToModel(model)]
		if (currentOptions === null){
			currentOptions = new Options(model, defaultChecker)
			optionsSet.add(currentOptions)
		}
	}
	
	def containsOptionsForModel(GraphModel model){
		optionsSet.findFirst[belongsToModel(model)]
	}
	
	def isShowingDescription(){
		currentOptions?.showingDescription
	}
	
	def isShowingHighlight(){
		currentOptions?.showingHighlight
	}
	
	def isWithSelection(){
		currentOptions?.withSelection
	}
	
	def isWithAutoCheck(){
		currentOptions?.autoCheck
	}
	
	def getModelChecker(){
		currentOptions?.checker
	}
	
	
	
	def toggleShowingDescription(){
		currentOptions.showingDescription = !currentOptions.showingDescription
	}
	
	def toggleShowingHighlight(){
		currentOptions.showingHighlight = !currentOptions.showingHighlight
	}
	
	def toggleWithSelection(){
		currentOptions.withSelection = !currentOptions.withSelection
	}
	
	def toggleAutoCheck(){
		currentOptions.autoCheck = !currentOptions.autoCheck
	}
	
	def setModelChecker(ModelChecker<?,?,?> checker){
		currentOptions.checker = checker
	}	
	
	private static class Options {
		val GraphModel model
		var boolean showingDescription
		var boolean showingHighlight
		var boolean withSelection
		var boolean autoCheck
		var ModelChecker<?,?,?> checker
		
		new (GraphModel model, ModelChecker<?,?,?> checker){
			this.model = model
			withSelection = false
			this.autoCheck = true
			this.showingHighlight = true
			this.showingDescription = false
			this.checker = checker
		} 
		
		def	belongsToModel(GraphModel model){
			this.model?.equals(model)
		}
	}
}

