package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import de.jabc.cinco.meta.core.ui.editor.ResourceContributor
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareEditorRegistry
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.GraphModel
import graphmodel.internal.InternalGraphModel
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.InternalEObject
import org.eclipse.emf.ecore.impl.EClassImpl
import org.eclipse.emf.ecore.impl.EObjectImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.linking.lazy.LazyLinkingResource
import org.eclipse.xtext.parser.IParseResult
import org.eclipse.xtext.util.CancelIndicator

abstract class GratextResource extends LazyLinkingResource {
	
	extension val ResourceExtension = new ResourceExtension
	
	private GraphModel model
	private Iterable<ResourceContributor> contributors
	private final HashMap<EObject,ResourceContributor> contributions = newHashMap
	private Runnable internalStateChangedHandler
	private Runnable newParseResultHandler
	private boolean skipInternalStateUpdate
	
	def Transformer getTransformer(InternalGraphModel model)
	
	def void removeTransformer(InternalGraphModel model)
	
	def String serialize() {
		val internalModel = model?.internalElement ?: getContent(InternalGraphModel)
		new Serializer(this, internalModel, getTransformer(internalModel)).run
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
	
	def Iterable<ResourceContributor> getResourceContributors() {
		contributors ?: if (file?.name != null) (
			contributors = PageAwareEditorRegistry.INSTANCE.get(file.name)
				.map[editor].map[resourceContributor].filterNull
		)
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
	
	def clear() {
		transact[
			for (content : newArrayList(getContents))
				unload
			getContents.clear
		]
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
			if (!skipInternalStateUpdate) {
				clear
				model = null
			}
		}
		updateInternalState(newParseResult)
	}
	
	override updateInternalState(IParseResult newParseResult) {
		parseResult = newParseResult
		val newRoot = newParseResult.rootASTElement
		if (newRoot != null) {
			if (!skipInternalStateUpdate) {
				if (model == null) {
					insert(0, newRoot)
					newRoot.reattachModificationTracker
					clearErrorsAndWarnings
					addSyntaxErrors
					transact[
						doLinking
						transformModel
						addContributions
					]
					internalStateChangedHandler?.run
				}
			} else {
				skipInternalStateUpdate = false
			}
		}
		newParseResultHandler?.run
	}
	
	def transformModel() {
		val gratextModel = getContent(InternalGraphModel)
		val transformer = getTransformer(gratextModel)
		model = transformer.transform(gratextModel).element
		val internal = (model as EObjectImpl).eInternalContainer
		remove(gratextModel)
		add(model.internalElement)
		model.internalElement = internal as InternalGraphModel
		removeTransformer(gratextModel)
	}
	
	def addContributions() {
		resourceContributors?.forEach[contributor|
			contributor.contributeToResource(this)?.forEach[contribution|
				contributions.put(contribution, contributor)
			]
		]
	}
	
	override resolveLazyCrossReferences(CancelIndicator mon) {
		getContents
			.filter[isResolveCrossReferencesRequired]
			.forEach[resolveCrossReferences(mon ?: CancelIndicator.NullImpl)]
	}
	
	def isResolveCrossReferencesRequired(EObject obj) {
		val contributor = contributions.get(obj)
		(contributor == null) || contributor.isResolveCrossReferencesRequired(obj)
	}
	
	def void resolveCrossReferences(EObject obj, CancelIndicator monitor) {
		if (monitor.canceled) return;
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