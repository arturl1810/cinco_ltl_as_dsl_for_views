package de.jabc.cinco.meta.plugin.modelchecking.runtime.util

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import org.eclipse.core.runtime.Platform
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.ModelCheckingAdapter
import java.util.concurrent.atomic.AtomicReference
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.Highlight
import org.eclipse.graphiti.util.IColorConstant
import java.util.Set
import graphmodel.internal.impl.InternalModelElementImpl
import graphmodel.Node
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import java.util.function.Supplier
import graphmodel.GraphModel
import de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker.ModelChecker
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel

class ModelCheckingRuntimeExtension {
	extension WorkbenchExtension = new WorkbenchExtension
	
	static final String ADAPTER_EXTENSION_ID = "de.jabc.cinco.meta.plugin.modelchecking.runtime.adapter"
	static final String CHECKER_EXTENSION_ID = "de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker"
	
	static Highlight currentHighlight
	
	private def getModelCheckAdapters(){
		val adapters = newArrayList
		val configElements = Platform.extensionRegistry
			.getConfigurationElementsFor(ADAPTER_EXTENSION_ID)
		for (element : configElements){
			val o = element.createExecutableExtension("class")
			if (o instanceof ModelCheckingAdapter) {
				adapters.add(o)
			}
		}
		if (adapters.empty){
			println("Adapters are empty")
		}
		adapters
	}
	
	def getModelCheckers(){
		val checkers = newArrayList
		val configElements = Platform.extensionRegistry
			.getConfigurationElementsFor(CHECKER_EXTENSION_ID)
		for (element : configElements){
			val o = element.createExecutableExtension("class")
			if (o instanceof ModelChecker<?,?,?>) {
				checkers.add(o)
			}
		}
		if (checkers.empty){
			println("Checkers are empty")
		}
		checkers
	}
	
	def getActiveAdapter() {
		activeModel.adapter
	}
	
	def getAdapter(GraphModel model){
		modelCheckAdapters?.findFirst[it.canHandle(model)]
	}
	
	def getActiveModel(){
		syncedGet[activeGraphModel]
	}
	
	def buildCheckableModel(ModelCheckingAdapter adapter, CheckableModel<?,?> model, boolean withSelection){
		adapter.buildCheckableModel(syncedGet[activeGraphModel], model, withSelection)
	}
	
	def buildCheckableModel(CheckableModel<?,?> model, boolean withSelection){
		buildCheckableModel(syncedGet[activeAdapter], model, withSelection)
	}
	
	def fulfills(ModelCheckingAdapter adapter, CheckableModel<?,?> model, Set<Node> satisfying){
		adapter.fulfills(activeModel, model, satisfying)
	}
	
	def fulfills(CheckableModel<?,?> model, Set<Node> satisfying){
		activeAdapter.fulfills(model,satisfying)
	}
	
	def getSelectedElementIds(){
		val elements = syncedGet[activeDiagramEditor?.selectedPictogramElements]
		val ids = newArrayList
		elements?.forEach[
			val businessObject = syncedGet[it?.businessObject]
			if (businessObject instanceof InternalModelElementImpl){
				ids.add(businessObject?.element?.id)
			}
		]
		ids
	}	
	
	def setNewHighlight(Set<Node> nodes, IColorConstant color){
		highlightOff
		val highlight = new Highlight
		highlight.backgroundColor = color
		highlight.foregroundColor = IColorConstant.BLACK
		try {
			for (node : nodes){
				if (node !== null){
					highlight.add(node)
				}
			} 
			currentHighlight = highlight
		} catch (Exception e) {
			clearHighlight
		}
	}
	
	def clearHighlight(){
		highlightOff
		currentHighlight = new Highlight
	}
	
	def void highlightOn() {
		currentHighlight?.on()
	}
	
	def void highlightOff(){
		currentHighlight?.off()
	}
	
	def <V> syncedGet(Supplier<V> supplier){
		val AtomicReference<V> ref = new AtomicReference
		sync[ref.set(supplier.get)]
		ref.get
	}
	
	def <V> asyncGet(Supplier<V> supplier){
		val AtomicReference<V> ref = new AtomicReference
		async[ref.set(supplier.get)]
		ref.get
	}
	
	def <T extends Node> findPathsToFirst(Node node, Class<T> clazz, (T)=>boolean predicate){
		(new GraphModelExtension).findPathsToFirst(node, clazz, predicate)
	}
	
	def getNodeById(GraphModel model, String id){
		model.allNodes.findFirst[it.id == id]
	}
	
}