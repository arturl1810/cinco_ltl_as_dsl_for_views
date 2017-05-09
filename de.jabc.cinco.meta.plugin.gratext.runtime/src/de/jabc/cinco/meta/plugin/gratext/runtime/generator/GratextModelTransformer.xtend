package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import java.util.ArrayList
import java.util.IdentityHashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature

class GratextModelTransformer {
	
	private Map<IdentifiableElement,IdentifiableElement> counterparts = new IdentityHashMap
	private List<InternalEdge> edges = new ArrayList

	private EFactory baseModelFct
	private EPackage baseModelPkg
	private EClass baseModelCls
	
	GraphModel baseModel
	
//	private String idSuffix
	
	new (EFactory modelFactory, EPackage modelPackage, EClass modelClass) {
		baseModelFct = modelFactory
		baseModelPkg = modelPackage
		baseModelCls = modelClass
	}
	
	def GraphModel transform(InternalGraphModel model) {
		model.map
		return baseModel
	}
	
//	def GraphModel transform(InternalGraphModel model, String idSuffix) {
//		this.idSuffix = idSuffix
//		model.map
//	}
	
	def getCounterpart(EObject elm) {
		counterparts.get(elm)
	}
	
	def getEdges() {
		edges
	}
	
	private def cache(IdentifiableElement baseElm, IdentifiableElement gtxElm) {
		counterparts.put(baseElm, gtxElm)
		counterparts.put(gtxElm, baseElm)
		switch baseElm {
			InternalEdge: edges.add(baseElm)
		}
	}
	
	private def <T extends InternalGraphModel> T map(T model) {
		val cp = model.counterpart
		if (cp != null)
			return cp as T
		baseModel = baseModelFct.create(baseModelCls) as GraphModel
		val internalModel = baseModel.internalElement as T
//		println("The Internal Element: "+internalModel)
		cache(internalModel, model)
		internalModel.attributes.map(internalModel)
		internalModel.references.map(internalModel)
//		if (idSuffix != null && internalModel.id.endsWith(idSuffix))
//			internalModel.id = internalModel.id.substring(0, internalModel.id.length - idSuffix.length)
		model.modelElements.forEach[
			internalModel.modelElements.add(it.map)
		]
		internalModel.modelElements.addAll(edges)
		return internalModel
	}
	
	private def InternalModelElement map(InternalModelElement elm) {
		val cp = elm.counterpart
		if (cp != null)
			return cp as InternalModelElement
		val baseElm = elm.toBase
		cache(baseElm.internalElement, elm)
		counterparts.put(baseElm, elm)
		baseElm.internalElement.attributes.map(baseElm.internalElement)
		baseElm.internalElement.references.map(baseElm.internalElement)
//		if (idSuffix != null && baseElm.id.endsWith(idSuffix))
//			baseElm.id = baseElm.id.substring(0, baseElm.id.length - idSuffix.length)
		return baseElm.internalElement
	}
	
	private def map(List<? extends EStructuralFeature> ftrs, IdentifiableElement elm) {
//		println("Map Attributes/EReferences of: "+ elm)
		ftrs.forEach[
			switch it {
				EAttribute: it.map(elm)
				EReference: it.map(elm)
			}
		]
	}
	
	private def map(EAttribute attr, IdentifiableElement elm) {
		val value = elm.counterpart.eGet(attr)
		elm.eSet(attr, value)
	}
	
	private def map(EReference ref, IdentifiableElement elm) {
		if (!"element".equals(ref.name)) {
			val value = elm.counterpart.eGet(ref).mapValue
			elm.eSet(ref, value)
		}
	}
	
	private def Object mapValue(Object value) {
		switch value {
			InternalGraphModel: value.map
			InternalModelElement: value.map
			List<?>: value.map[mapValue]
			EObject: value
			case null: value
			default: { warn("unmatched value type: " + value); value }
		}
	}
	
	private def attributes(EObject elm) {
		elm?.eClass?.getEAllAttributes
	}
	
	private def references(EObject elm) {
		elm?.eClass?.getEAllReferences
	}
	
	private def toBase(InternalModelElement elm) {
		elm.eClass.getESuperTypes
			.filter[suty | {
				baseModelPkg.eContents.filter(EClass).exists[name === suty.name]
			}]
			.map[suty | {
				baseModelFct.create(suty)
			}]
			.reduce[p1, p2 | p1] as ModelElement
	}
	
	private def warn(String msg) {
		System.err.println("[" + this.class.simpleName + "] " + msg)
	}
}
