package de.jabc.cinco.meta.plugin.gratext.runtime.resource

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

import static org.eclipse.emf.ecore.util.EcoreUtil.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.setID

class Transformer {
	
	private static val baseClassRegistry = <EClass, Class<?>> newHashMap
	
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
			gtxInternal.modelElements.sortBy[index].forEach[elm|
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
			attributes.forEach[attr | baseInternal => [
				val deliver = eDeliver
				eSetDeliver(false)
				eSet(attr, gtxInternal.eGet(attr))
				eSetDeliver(deliver)
			]]
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
							val deliver = ref.eDeliver
							ref.eSetDeliver(false)
							baseInternal.eSet(ref, getBaseElement(theID).element)
							ref.eSetDeliver(deliver)
						]
						refValue
					}
				}
				default: refValue.transformValue
			}
			if (baseValue != null) {
				val deliver = ref.eDeliver
				ref.eSetDeliver(false)
				baseInternal.eSet(ref, baseValue)
				ref.eSetDeliver(deliver)
			}
		]
	}
	
	private def Object transformValue(Object value) {
		switch value {
			InternalGraphModel: value.transform
			InternalIdentifiableElement: value.transform
			List<?>: value.sortBy[index].map[transformValue]
			EObject: value
			case null: value
			default: { warn("unmatched value type: " + value); value }
		}
	}
	
	// additional dispatch method is generated
	dispatch def int getIndex(Object it) {
		-1
	}
	
	def toBaseInternal(InternalIdentifiableElement it) {
		(#[eClass] + eClass.ESuperTypes)
			.filter[modelPackage.knows(it)]
			.map[modelFactory.create(it)]
			.filter(IdentifiableElement)
			.head.internalElement
	}
	
	def Class<?> getBaseClass(InternalIdentifiableElement elm) {
		baseClassRegistry.get(elm.eClass)
		?: elm.toBaseInternal.element.class => [
			baseClassRegistry.put(elm.eClass, it)
		]
	}
	
	private def knows(EPackage it, EClass elmClazz) {
		eContents.filter(EClass).exists[name == elmClazz.name]
	}
	
	private def getAttributes(EObject elm) {
		elm?.eClass?.getEAllAttributes
	}
	
	private def getReferences(EObject elm) {
		elm?.eClass?.getEAllReferences
	}
	
	def getCounterpart(EObject elm) {
		counterparts.get(elm)
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
