package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import graphmodel.IdentifiableElement
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

import static extension org.eclipse.emf.ecore.util.EcoreUtil.setID
import static extension org.eclipse.emf.ecore.util.EcoreUtil.generateUUID

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
	
	def transform(InternalGraphModel gtxInternal) {
		val baseModel = (gtxInternal as InternalIdentifiableElement).transform
		baseModel as InternalGraphModel => [
			gtxInternal.modelElements.forEach[elm|
				modelElements.add(elm.transform as InternalModelElement)
			]
			modelElements.addAll(edges)
		]
	}
	
	def transform(InternalIdentifiableElement gtxInternal) {
		transform(gtxInternal, true)
	}
	
	def transform(InternalIdentifiableElement gtxInternal, boolean resolveReferences) {
		gtxInternal.counterpart
		?:{ 
			gtxInternal.toBaseInternal => [
				transformAttributes(gtxInternal)
				cache(it, gtxInternal)
				if (resolveReferences)
					transformReferences(gtxInternal)
			]
		}
	}
	
	private def transformAttributes(InternalIdentifiableElement baseInternal, InternalIdentifiableElement gtxInternal) {
		baseInternal => [
			attributes.forEach[attr|
				baseInternal.eSet(attr, gtxInternal.eGet(attr))
			]
			val baseId = if (id.nullOrEmpty) generateUUID else id
			element.setID(baseId)
			setID(baseId + "_INTERNAL")
		]
	}
	
	private def transformReferences(InternalIdentifiableElement baseInternal, InternalIdentifiableElement gtxInternal) {
		baseInternal.references.filter[name != "element"].forEach[ref|
			val refValue = gtxInternal.eGet(ref)
			val baseValue = switch refValue {
				IdentifiableElement: {
					refValue.baseElement?.element
					?: {
						addReplacementRequest(refValue.id) [theID|
							baseInternal.eSet(ref, getBaseElement(theID).element)
						]
						refValue
					}
				}
				default: refValue.transformValue
			}
			if (baseValue != null)
				baseInternal.eSet(ref, baseValue)
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
	
	def toBaseInternal(InternalIdentifiableElement it) {
		(#[eClass] + eClass.ESuperTypes)
			.filter[modelPackage.knows(it)]
			.map[modelFactory.create(it)]
			.filter(IdentifiableElement)
			.head.internalElement
	}
	
	private def knows(EPackage it, EClass elmClazz) {
		eContents.filter(EClass).exists[name == elmClazz.name]
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
	
	def getBaseElement(IdentifiableElement elm) {
		elm.id.baseElement
	}
	
	def getBaseElement(String id) {
		baseElements.get(id)
	}
	
	def registerBaseElement(String id, InternalIdentifiableElement baseInternal) {
		if (!id.nullOrEmpty) {
			baseElements.put(id, baseInternal)
			replacements.get(id).forEach[apply(id)]
		}
	}
	
	def addReplacementRequest(String id, (String)=>void replacement) {
		replacements.get(id).add(replacement)
	}
	
	private def cache(InternalIdentifiableElement baseInternal, InternalIdentifiableElement gtxInternal) {
		counterparts => [
			put(baseInternal, gtxInternal)
			put(gtxInternal, baseInternal)
		]
		registerBaseElement(gtxInternal.id, baseInternal)
		switch baseInternal {
			InternalEdge: edges.add(baseInternal)
		}
	}
	
	private def warn(String msg) {
		System.err.println("[" + class.simpleName + "] " + msg)
	}
}
