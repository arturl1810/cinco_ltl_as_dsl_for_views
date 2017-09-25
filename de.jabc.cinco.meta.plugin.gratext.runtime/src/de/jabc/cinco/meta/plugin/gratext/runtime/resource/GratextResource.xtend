package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.xtext.parser.IParseResult

import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.emf.ecore.impl.EClassImpl
import org.eclipse.emf.ecore.InternalEObject
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.plugin.gratext.runtime.generator.Modelizer
import de.jabc.cinco.meta.plugin.gratext.runtime.generator.Serializer

abstract class GratextResource extends LazyLinkingResource {
	
	extension val ResourceExtension = new ResourceExtension
	
	private Diagram diagram
	private EObject model
	private Modelizer modelizer
	private Runnable internalStateChangedHandler
	private Runnable newParseResultHandler
	private boolean skipInternalStateUpdate
	
	def Modelizer createModelizer()
	
	def Serializer createSerializer()
	
	def serialize() {
		createSerializer.run
	}
	
	override doSave(OutputStream outputStream, Map<?, ?> options) {
		new OutputStreamWriter(outputStream, encoding) => [
			write(serialize)
			flush
		]
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
	
	def onNewParseResult(Runnable runnable) {
		newParseResultHandler = runnable
	}
	
	def getContent(int index) {
		getContents.get(index)
	}
	
	def getModelizer() {
		modelizer ?: (modelizer = createModelizer)
	}
	
	override getEObjectByID(String id) {
    	val eObject = intrinsicIDToEObjectMap?.get(id)
  		if (eObject != null)
    		return eObject
		getContents.tail.toList.allProperContents.getEObjectById(id)
		?: if (getContents.size > 0) {
			getContents.head.allProperContents.getEObjectById(id)
		}
	}
	
	private def getEObjectById(TreeIterator<EObject> iterator, String id) {
		while (iterator.hasNext) {
			val eObject = iterator.next
			val eObjectId = EcoreUtil.getID(eObject)
			intrinsicIDToEObjectMap?.put(eObjectId,eObject)
			if (eObjectId == id)
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
	
	def skipInternalStateUpdate() {
		skipInternalStateUpdate = true 
	}
	
	override updateInternalState(IParseResult oldParseResult, IParseResult newParseResult) {
		val oldRoot = oldParseResult?.rootASTElement
		if (oldRoot != null && oldRoot != newParseResult.rootASTElement) {
			if (getContents.contains(oldRoot)) {
				oldRoot.unload
				remove(oldRoot)
			}
			if (!skipInternalStateUpdate) {
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
			if (!skipInternalStateUpdate) {
				if (diagram == null || !getContents.contains(diagram)) {
					insert(0, newRoot)
					newRoot.reattachModificationTracker
					clearErrorsAndWarnings
					addSyntaxErrors
					transact[
						doLinking
						createModelizer.run(this)
						diagram = getContent(0) as Diagram
						model = getContent(1)
					]
					modelizer = createModelizer
					internalStateChangedHandler?.run
				}
			} else {
				skipInternalStateUpdate = false
			}
		}
		newParseResultHandler?.run
		// for debugging only
		if (getContents.size != 2) {
			System.err.println("[" + getClass().getSimpleName() + "] WARN: unexpected number of content objects")
			getContents.forEach[System.err.println(" > content: " + it)]
		}
	}
	
	override resolveLazyCrossReferences(CancelIndicator mon) {
		getContents.forEach[
			resolveCrossReferences(mon ?: CancelIndicator.NullImpl)
		]
	}
	
	def resolveCrossReferences(Object obj, CancelIndicator monitor) {
		if (monitor.canceled) return;
		
		if (obj instanceof EObject && !(obj instanceof Diagram)) {
			val iEobj = obj as InternalEObject
			val cls = iEobj.eClass
			val sup = cls.EAllStructuralFeatures as EClassImpl.FeatureSubsetSupplier
			sup.crossReferences?.forEach[
				if (monitor.canceled) return;
				if (isPotentialLazyCrossReference)
					doResolveLazyCrossReference(iEobj, it)
			]
			EcoreUtil.getAllContents(iEobj, true).forEachRemaining[
				resolveCrossReferences(monitor)
			]
		}
	}
}