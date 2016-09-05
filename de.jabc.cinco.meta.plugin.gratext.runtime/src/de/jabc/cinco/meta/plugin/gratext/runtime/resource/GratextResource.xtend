package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.xtext.parser.IParseResult

import static de.jabc.cinco.meta.plugin.gratext.runtime.util.GratextUtils.edit
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.util.EcoreUtil

abstract class GratextResource extends LazyLinkingResource {
	
	private Diagram diagram
	private EObject model
	private Runnable internalStateChangedHandler
	
	def void generateContent()
	
	def String serialize()
	
	override doSave(OutputStream outputStream, Map<?, ?> options) {
		val writer = new OutputStreamWriter(outputStream, encoding)
		writer.write(serialize)
		writer.flush
	}
	
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
	
	override getEObjectByID(String id) {
    	val map = getIntrinsicIDToEObjectMap
    	if (map != null) {
      		val eObject = map.get(id)
      		if (eObject != null)
        		return eObject
    	}
		getContents.tail.toList.allProperContents.getEObjectById(id)
		?: if (getContents.size > 0) {
			getContents.head.allProperContents.getEObjectById(id)
		}
	}
	
	private def getEObjectById(TreeIterator<EObject> iterator, String id) {
		while (iterator.hasNext) {
			val eObject = iterator.next
			val eObjectId = EcoreUtil.getID(eObject)
			if (getIntrinsicIDToEObjectMap != null)
				getIntrinsicIDToEObjectMap.put(eObjectId,eObject)
			if (eObjectId.equals(id))
	          return eObject
		}
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
					generateContent
					diagram = getContent(0) as Diagram
					model = getContent(1)
				]
				internalStateChangedHandler?.run
			}
		}
		// for debugging only
		if (getContents.size != 2) {
			System.err.println("[" + getClass().getSimpleName() + "] WARN: unexpected number of content objects")
			getContents.forEach[System.err.println(" > content: " + it)]
		}
	}
	
	def transact(Runnable change) {
		edit(this).transact(change)
	}
}