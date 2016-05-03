package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.xtext.parser.IParseResult

import static de.jabc.cinco.meta.plugin.gratext.runtime.util.GratextUtils.edit

abstract class GratextResource extends LazyLinkingResource {
	
	private Diagram diagram
	private EObject model
	private Runnable internalStateChangedHandler
	
	def void generateModel(Resource resource);
	
	override clearInternalState() {
		unload(getContents)
		transact[getContents.clear]
		clearErrorsAndWarnings
		setParseResult(null)
	}
	
	def onInternalStateChanged(Runnable runnable) {
		internalStateChangedHandler = runnable
	}
	
	def getContent(int index) {
		getContents.get(index)
	}
	
	def add(EObject object) {
		transact[getContents.add(object)]
	}
	
	def insert(int index, EObject object) {
		transact[getContents.add(index, object)]
	}
	
	def remove(EObject... objects) {
		transact[getContents.removeAll(objects)]
	}
	
	def unload(EObject... objects) {
		objects?.filterNull.forEach[unload]
	}
	
	def update(String newText) {
		update(0, getParseResult().getRootNode().getText().length(), newText)
	}
	
	override updateInternalState(IParseResult oldParseResult, IParseResult newParseResult) {
		val oldRoot = oldParseResult?.rootASTElement
		if (oldRoot != null && oldRoot != newParseResult.rootASTElement) {
			oldRoot.unload
			diagram.unload
			remove(oldRoot, diagram, model)
		}
		updateInternalState(newParseResult)
	}
	
	override updateInternalState(IParseResult newParseResult) {
		parseResult = newParseResult
		val newRoot = newParseResult.rootASTElement
		if (newRoot != null) {
			if (diagram == null || !getContents.contains(diagram)) {
				insert(0, newRoot)
				newRoot.reattachModificationTracker
				clearErrorsAndWarnings
				addSyntaxErrors
				transact[
					doLinking
					generateModel(this)
					diagram = getContent(0) as Diagram
					model = getContent(1)
				]
				insert(2, newRoot)
				internalStateChangedHandler?.run
			}
		}
		// for debugging only
		if (getContents.size != 3) {
			System.err.println("[" + getClass().getSimpleName() + "] WARN: unexpected number of content objects")
			getContents.forEach[System.err.println(" > content: " + it)]
		}
	}
	
	def transact(Runnable change) {
		edit(this).transact(change)
	}
}