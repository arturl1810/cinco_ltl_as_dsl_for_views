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
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.emf.ecore.impl.EClassImpl
import org.eclipse.emf.ecore.InternalEObject

abstract class GratextResource extends LazyLinkingResource {
	
	private Diagram diagram
	private EObject model
	private Runnable internalStateChangedHandler
	private boolean saveTriggered
	
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
	
	def informAboutSave() {
		saveTriggered = true 
	}
	
	override updateInternalState(IParseResult oldParseResult, IParseResult newParseResult) {
		val oldRoot = oldParseResult?.rootASTElement
		if (oldRoot != null && oldRoot != newParseResult.rootASTElement) {
			if (getContents.contains(oldRoot)) {
				oldRoot.unload
				remove(oldRoot)
			}
			if (!saveTriggered) {
				diagram.unload
				remove(diagram, model)
			}
		}
		updateInternalState(newParseResult)
	}
	
	override updateInternalState(IParseResult newParseResult) {
		parseResult = newParseResult
		val newRoot = newParseResult.rootASTElement
		if (newRoot != null) {
			if (saveTriggered) {
				saveTriggered = false
			}
			else if (diagram == null || !getContents.contains(diagram)) {
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
	
	override resolveLazyCrossReferences(CancelIndicator mon) {
		val monitor = 
			if (mon == null) CancelIndicator.NullImpl
			else mon
		getContents.forEach[it.resolveLazyCrossReferences(monitor)]
	}
	
	def resolveLazyCrossReferences(Object obj, CancelIndicator monitor) {
		if (monitor.canceled) return;
		
		if (obj instanceof EObject && !(obj instanceof Diagram)) {
			val iEobj = obj as InternalEObject
			val cls = iEobj.eClass
			val sup = cls.getEAllStructuralFeatures as EClassImpl.FeatureSubsetSupplier
			sup.crossReferences?.forEach[
				if (monitor.canceled) return;
				if (it.isPotentialLazyCrossReference)
					doResolveLazyCrossReference(iEobj, it)
			]
			
			EcoreUtil.getAllContents(iEobj, true).forEachRemaining[
				it.resolveLazyCrossReferences(monitor)
			]
		}
	}
	
	def transact(Runnable change) {
		edit(this).transact(change)
	}
}