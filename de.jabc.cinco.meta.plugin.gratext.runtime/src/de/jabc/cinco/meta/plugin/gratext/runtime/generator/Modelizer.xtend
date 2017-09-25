package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.IdentifiableElement
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.impl.EObjectImpl
import org.eclipse.emf.ecore.resource.Resource
import graphmodel.GraphModel

abstract class Modelizer {
	
	extension val ResourceExtension = new ResourceExtension
	
	protected NonEmptyRegistry<IdentifiableElement,List<EObject>> nodesInitialOrder = new NonEmptyRegistry[newArrayList]
	protected GratextModelTransformer transformer
	protected GraphModel model
	
	new(GratextModelTransformer transformer) {
		this.transformer = transformer
	}
	
	def run(Resource it) {
		val gratextModel = getContent(InternalGraphModel)
		nodesInitialOrder.clear
		gratextModel.cacheInitialOrder
		model = transformer.transform(gratextModel).element
		val internal = (model as EObjectImpl).eInternalContainer()
		transact[
			contents.remove(gratextModel)
			contents.add(0, model.internalElement)
		]
		model.internalElement = internal as InternalGraphModel
	}
	
	def void cacheInitialOrder(InternalModelElementContainer container) {
		val children = nodesInitialOrder.get(container)
		container.modelElements.forEach[
			if (elementIndex < 0)
				elementIndex = children.size
			children.add(it)
			switch it {
				InternalModelElementContainer: cacheInitialOrder
			}	
		]
	}
	
	def getInitialIndex(InternalModelElement it) {
		nodesInitialOrder.get(container.counterpart).indexOf(counterpart)
	}
		
	def getCounterpart(EObject elm) {
		transformer.getCounterpart(elm)
	}
	
	def getTransformer() {
		this.transformer
	}
	
	def int getElementIndex(IdentifiableElement element)
	
	def void setElementIndex(IdentifiableElement element, int i)
}
