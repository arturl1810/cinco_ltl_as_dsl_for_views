package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalIdentifiableElement
import graphmodel.internal.InternalModelElement
import java.util.IdentityHashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import graphmodel.internal.InternalType
import graphmodel.Type
import graphmodel.GraphmodelPackage

class GratextModelTransformer {
	
	private Map<IdentifiableElement,IdentifiableElement> counterparts = new IdentityHashMap
	private List<InternalEdge> edges = newArrayList

	private EFactory modelFactory
	private EPackage modelPackage
	private EClass modelClass
	
	new (EFactory modelFactory, EPackage modelPackage, EClass modelClass) {
		this.modelFactory = modelFactory
		this.modelPackage = modelPackage
		this.modelClass = modelClass
	}
	
	def transform(InternalGraphModel model) {
		val cp = model.counterpart
		if (cp != null)
			return cp as InternalGraphModel
		val baseModel = modelFactory.create(modelClass) as GraphModel
		baseModel.internalElement => [
			cache(it, model)
			transformAttributes
			transformReferences
			model.modelElements.forEach[me|
				it.modelElements.add(me.transform)
			]
			modelElements.addAll(edges)
		]
	}
	
	def transform(InternalModelElement element) {
		val cp = element.counterpart
		if (cp != null)
			return cp as InternalModelElement
		val baseElm = element.createBaseModelElement => [
			cache(internalElement, element)
			counterparts.put(it, element)
			transformAttributes
			transformReferences
		]
		return baseElm.internalElement
	}

	private def transformAttributes(ModelElement elm) {
		elm.internalElement.transformAttributes
	}
	
	private def transformAttributes(InternalIdentifiableElement element) {
		element.attributes.forEach[attr|
			element.eSet(attr, element.counterpart.eGet(attr))
		]
	}

	private def transformReferences(ModelElement it) {
		internalElement.transformReferences
	}
	
	private def transformReferences(InternalIdentifiableElement element) {
		element.references.forEach[ref|
			if (ref.name != "element") {
				element.eSet(ref, element.counterpart.eGet(ref).transformValue)
			}
		]
	}
	
	private def Object transformValue(Object value) {
		switch value {
			InternalGraphModel: value.transform
			InternalModelElement: value.transform
			List<?>: value.map[transformValue]
			EObject: value
			case null: value
			default: { warn("unmatched value type: " + value); value }
		}
	}
	
	def createBaseModelElement(InternalModelElement elm) {
		createBaseElement(elm) as ModelElement
	}
	
	def createBaseType(InternalType elm) {
		createBaseElement(elm) as Type
	}
	
	def createBaseElement(InternalIdentifiableElement elm) {
		elm.eClass.ESuperTypes
			.filter[
				modelPackage.eContents.filter(EClass).exists[name === it.name]
			]
			.map[modelFactory.create(it)]
			.head as IdentifiableElement
	}
	
	private def getAttributes(EObject elm) {
		elm?.eClass?.EAllAttributes
	}
	
	private def getReferences(EObject elm) {
		elm?.eClass?.EAllReferences
	}
	
	def getCounterpart(EObject elm) {
		counterparts.get(elm)
	}
	
	def getEdges() {
		edges
	}
	
	private def cache(IdentifiableElement baseElm, IdentifiableElement gtxElm) {
		counterparts => [
			put(baseElm, gtxElm)
			put(gtxElm, baseElm)
		]
		switch baseElm {
			InternalEdge: edges.add(baseElm)
		}
	}
	
	private def warn(String msg) {
		System.err.println("[" + class.simpleName + "] " + msg)
	}
}
