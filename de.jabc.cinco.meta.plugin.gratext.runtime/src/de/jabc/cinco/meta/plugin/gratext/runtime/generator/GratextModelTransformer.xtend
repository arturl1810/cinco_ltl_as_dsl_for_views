package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.Edge
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.ModelElement

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import java.util.IdentityHashMap

class GratextModelTransformer {
	
	private Map<IdentifiableElement,IdentifiableElement> counterparts = new IdentityHashMap
	private List<Edge> edges = new ArrayList

	private EFactory baseModelFct
	private EPackage baseModelPkg
	private EClass baseModelCls
	
	private String idSuffix
	
	new (EFactory modelFactory, EPackage modelPackage, EClass modelClass) {
		baseModelFct = modelFactory
		baseModelPkg = modelPackage
		baseModelCls = modelClass
	}
	
	def <T extends GraphModel> T transform(T model) {
		model.map
	}
	
	def <T extends GraphModel> T transform(T model, String idSuffix) {
		this.idSuffix = idSuffix
		model.map
	}
	
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
			Edge: edges.add(baseElm)
		}
	}
	
	private def <T extends GraphModel> T map(T model) { 
		val cp = model.counterpart
		if (cp != null)
			return cp as T
		val baseModel = baseModelFct.create(baseModelCls) as T
		cache(baseModel, model)
		baseModel.attributes.map(baseModel)
		baseModel.references.map(baseModel)
		if (idSuffix != null && baseModel.id.endsWith(idSuffix))
			baseModel.id = baseModel.id.substring(0, baseModel.id.length - idSuffix.length)
		model.modelElements.forEach[
			baseModel.modelElements.add(it.map)
		]
		baseModel.modelElements.addAll(this.edges)
		return baseModel
	}
	
	private def ModelElement map(ModelElement elm) {
		val cp = elm.counterpart
		if (cp != null)
			return cp as ModelElement
		val baseElm = elm.toBase
		cache(baseElm, elm)
		baseElm.attributes.map(baseElm)
		baseElm.references.map(baseElm)
		if (idSuffix != null && baseElm.id.endsWith(idSuffix))
			baseElm.id = baseElm.id.substring(0, baseElm.id.length - idSuffix.length)
		return baseElm
	}
	
	private def map(List<? extends EStructuralFeature> ftrs, IdentifiableElement elm) {
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
		val value = elm.counterpart.eGet(ref).mapValue
		elm.eSet(ref, value)
	}
	
	private def Object mapValue(Object value) {
		switch value {
			GraphModel: value.map
			ModelElement: value.map
			List<?>: value.map[mapValue]
			EObject: value
			case null: value
			default: { warn("unmatched value type: " + value); value }
		}
	}
	
	private def attributes(EObject elm) {
		elm.eClass.getEAllAttributes
	}
	
	private def references(EObject elm) {
		elm.eClass.getEAllReferences
	}
	
	private def toBase(ModelElement elm) {
		elm.eClass.getESuperTypes
			.filter[baseModelPkg.eContents.contains(it)]
			.map[baseModelFct.create(it)]
			.reduce[p1, p2 | p1] as ModelElement
	}
	
	private def warn(String msg) {
		System.err.println("[" + this.class.simpleName + "] " + msg)
	}
}
