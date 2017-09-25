package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.Type
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
	
	def transform(InternalGraphModel internal) {
		val baseModel = (internal as InternalIdentifiableElement).transform
		baseModel as InternalGraphModel => [
			internal.modelElements.forEach[elm|
				modelElements.add(elm.transform as InternalModelElement)
			]
			modelElements.addAll(edges)
		]
	}
	
	def transform(InternalIdentifiableElement internal) {
		val cp = internal.counterpart
		if (cp != null)
			return cp as InternalIdentifiableElement
		internal.createBaseElement.internalElement => [
			cache(it, internal)
			transformAttributes
			transformReferences
		]
	}
	
	private def transformAttributes(InternalIdentifiableElement internal) {
		internal.attributes.forEach[attr|
			internal.eSet(attr, internal.counterpart.eGet(attr))
		]
	}
	
	private def transformReferences(InternalIdentifiableElement internal) {
		internal.references.filter[name != "element"].forEach[ref|
			internal.eSet(ref, internal.counterpart.eGet(ref).transformValue)
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
	
	def createBaseElement(InternalIdentifiableElement elm) {
		elm.eClass.ESuperTypes
			.filter[modelPackage.eContents.filter(EClass).exists[name == it.name]]
			.map[modelFactory.create(it)]
			.head as IdentifiableElement
	}
	
	def InternalIdentifiableElement getInternalElement(IdentifiableElement it) {
		switch it {
			GraphModel: internalElement
			ModelElement: internalElement
			Type: internalElement
		}
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
