package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.Node
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.impl.EObjectImpl
import org.eclipse.emf.ecore.resource.Resource

import java.util.List

import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*

abstract class ModelBuilder {
	
	extension val ResourceExtension = new ResourceExtension
	
	protected NonEmptyRegistry<IdentifiableElement,List<EObject>> nodesInitialOrder = new NonEmptyRegistry[newArrayList]
	protected GratextModelTransformer transformer
	protected GraphModel model
	
	new(GratextModelTransformer transformer) {
		this.transformer = transformer
	}
	
	def run(Resource resource) {
		val gratextModel = resource.getContent(InternalGraphModel)
		nodesInitialOrder.clear
		gratextModel.cacheInitialOrder
		model = transformer.transform(gratextModel)
		val internal = (model as EObjectImpl).eInternalContainer()
		resource.edit[
			resource.contents.remove(gratextModel)
			resource.contents.add(0, model.internalElement)
		]
		model.internalElement = internal as InternalGraphModel
	}
	
	def void cacheInitialOrder(InternalModelElementContainer container) {
		val children = nodesInitialOrder.get(container)
		container.modelElements.forEach[
//			if (index < 0)
//				index = children.size
			children.add(it)
			switch it {
				InternalModelElementContainer: cacheInitialOrder
			}	
		]
	}
	
	def getInitialIndex(InternalModelElement node) {
		nodesInitialOrder.get(node.container.counterpart).indexOf(node.counterpart)
	}
		
	def getCounterpart(EObject elm) {
		transformer.getCounterpart(elm)
	}
	
	def getEdges() {
		transformer.edges
	}
	
	def getNodes() {
		model.modelElements.filter(Node)//.sortBy[(counterpart as InternalNode).index]
	}
	
//	def int getIndex(IdentifiableElement element)
//	
//	def void setIndex(IdentifiableElement element, int i)
	
}
