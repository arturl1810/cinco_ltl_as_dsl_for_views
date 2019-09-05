package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import de.jabc.cinco.meta.core.utils.registry.NonEmptyIdentityRegistry
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.Type
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalIdentifiableElement
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import graphmodel.internal.InternalType
import java.util.ArrayList
import java.util.IdentityHashMap
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.common.notify.Adapter
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference

import static org.eclipse.emf.ecore.util.EcoreUtil.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.setID

class Transformer {
	
	Map<InternalIdentifiableElement,InternalIdentifiableElement> counterparts = new IdentityHashMap
	Map<String,InternalIdentifiableElement> baseElements = newHashMap
	Map<String,List<(String)=>void>> replacements = new NonEmptyRegistry[newArrayList]
	Set<InternalIdentifiableElement> resolved = newHashSet
	List<InternalEdge> edges = newArrayList
	
	val nodesInitialOrder = new NonEmptyIdentityRegistry<InternalModelElementContainer,List<InternalModelElement>>[newArrayList]
	
	EFactory modelFactory
	EPackage modelPackage
	EClass modelClass
	
	new (EFactory modelFactory, EPackage modelPackage, EClass modelClass) {
		this.modelFactory = modelFactory
		this.modelPackage = modelPackage
		this.modelClass = modelClass
	}
	
	def transform(InternalGraphModel gtxInternal) {
		val baseModel = (gtxInternal as InternalIdentifiableElement).transform
		baseModel as InternalGraphModel => [
			gtxInternal.modelElements.sortBy[index].forEach[elm|
				val baseElm = elm.transform as InternalModelElement
				modelElements.add(baseElm)
			]
			modelElements.transferEdges
			modelElements.addAll(edges)
		]
	}
	
	def getNodesInitialOrder(InternalModelElementContainer container) {
		nodesInitialOrder.get(container)
	}
	
	def void transferEdges(List<InternalModelElement> list) {
		list.forEach[switch it {
			InternalNode: transferEdges
		}]
	}
	
	def void transferEdges(InternalNode node) {
		node.references.filter[name == "outgoingEdges"].forEach[ref|
			val edges = node.eGet(ref).transformValue
			if (edges !== null) {
				this.edges.addAll(edges as List<InternalEdge>)
			}
		]
		if (node instanceof InternalContainer)
			node.modelElements.transferEdges
	}
	
	def transform(InternalIdentifiableElement gtxInternal) {
		transform(gtxInternal, true)
	}
	
	def transform(InternalIdentifiableElement gtxInternal, boolean resolveReferences) {
		val cp = gtxInternal.counterpart
		?: {
			gtxInternal.toBaseInternal => [
				transformAttributes(gtxInternal)
				cache(it, gtxInternal)
			]
		}
		cp => [
			if (resolveReferences && !resolved.contains(gtxInternal)) {
				resolved.add(gtxInternal)
				transformReferences(gtxInternal)
			}
		]
	}
	
	private def transformAttributes(InternalIdentifiableElement baseInternal, InternalIdentifiableElement gtxInternal) {
		baseInternal => [
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
							baseInternal.setFeatureValue(ref, getBaseElement(theID).element)
						]
						refValue
					}
				}
				default: refValue.transformValue
			}
			if (baseValue !== null) {
				baseInternal.setFeatureValue(ref, baseValue)
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
	
	private def setFeatureValue(InternalIdentifiableElement baseInternal, EReference ref, Object value) {
		val refDeliver = ref.eDeliver
		ref.eSetDeliver(false)
		val baseDeliver = baseInternal.eDeliver
		baseInternal.eSetDeliver(false)
		
		baseInternal.eSet(ref, value)
		
		baseInternal.eSetDeliver(baseDeliver)
		ref.eSetDeliver(refDeliver)
	}
	
	// additional dispatch method is generated
	dispatch def int getIndex(Object it) {
		-1
	}
	
	def getInitialIndex(InternalModelElement elm) {
		if (elm.container !== null) {
			nodesInitialOrder.get(elm.container).indexOf(elm)
		} else -1
	}
	
	def toBaseInternal(InternalIdentifiableElement internal) {
		val baseNonInternal = (#[internal.eClass] + internal.eClass.ESuperTypes)
			.filter[modelPackage.knows(it)]
			.map[modelFactory.create(it)]
			.filter(IdentifiableElement)
			.head
		
		val adapters = new ArrayList<Adapter>(baseNonInternal.internalElement.eAdapters)
		baseNonInternal.internalElement.eAdapters.clear
		
		switch it:baseNonInternal {
			GraphModel: internalElement = internal as InternalGraphModel
			ModelElement: internalElement = internal as InternalModelElement
			Type: internalElement = internal as InternalType
		}
		
		for (adapter : adapters)
			internal.eAdapters.add(adapter)
		
		return internal
	}
	
	private def knows(EPackage it, EClass elmClazz) {
		eContents.filter(EClass).exists[name == elmClazz.name]
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
