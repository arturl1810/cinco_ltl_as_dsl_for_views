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
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import graphmodel.internal.InternalType
import org.eclipse.emf.ecore.util.EcoreUtil

class GratextModelTransformer {
	
	private Map<InternalIdentifiableElement,InternalIdentifiableElement> counterparts = new IdentityHashMap
	private Map<String,InternalIdentifiableElement> baseElements = newHashMap
	private Map<String,List<(String)=>void>> replacements = new NonEmptyRegistry[newArrayList]
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
		if (cp != null) {
			return cp as InternalIdentifiableElement
		}
		internal.createBaseElement.internalElement => [
			cache(it, internal)
			transformAttributes(internal)
			transformReferences(internal)
		]
	}
	
	private def transformAttributes(InternalIdentifiableElement baseElm, InternalIdentifiableElement gratextElm) {
		baseElm.attributes.forEach[attr|
			val v = gratextElm.eGet(attr)
			baseElm.eSet(attr, v)
		]
		EcoreUtil.setID(baseElm.element, baseElm.id)
		EcoreUtil.setID(baseElm, baseElm.id + "_INTERNAL")
	}
	
	def getNonInternal(InternalIdentifiableElement it) {
		switch it {
			InternalGraphModel: element
			InternalModelElement: element
			InternalType: element
			default: it
		}
	}
	
	private def transformReferences(InternalIdentifiableElement baseElm, InternalIdentifiableElement gratextElm) {
		baseElm.references.filter[name != "element"].forEach[ref|
			val value = gratextElm.eGet(ref)
			val baseValue = switch value {
				GraphModel, ModelElement, Type: {
					value.internalElement.baseElement?.nonInternal
					?: {
						addReplacementRequest(value.internalElement.id)[
							val be = baseElement.nonInternal
							baseElm.eSet(ref, be)
						]
						null
					}
				}
				default: value.transformValue
			}
			if (baseValue != null)
				baseElm.eSet(ref, baseValue)
		]
	}
	
	private def Object transformValue(Object value) {
		switch value {
			InternalGraphModel: value.transform
			InternalIdentifiableElement: value.transform
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
	
	def getBaseElement(InternalIdentifiableElement elm) {
		elm.id.baseElement
	}
	
	def getBaseElement(String id) {
		baseElements.get(id)
	}
	
	def registerBaseElement(String id, InternalIdentifiableElement baseElm) {
		if (!id.nullOrEmpty) {
			baseElements.put(id, baseElm)
			replacements.get(id).forEach[apply(id)]
		}
	}
	
	def addReplacementRequest(String id, (String)=>void replacement) {
		replacements.get(id).add(replacement)
	}
	
	private def cache(InternalIdentifiableElement baseElm, InternalIdentifiableElement gtxElm) {
		counterparts => [
			put(baseElm, gtxElm)
			put(gtxElm, baseElm)
		]
		registerBaseElement(gtxElm.id, baseElm)
		switch baseElm {
			InternalEdge: edges.add(baseElm)
		}
	}
	
	private def warn(String msg) {
		System.err.println("[" + class.simpleName + "] " + msg)
	}
}
