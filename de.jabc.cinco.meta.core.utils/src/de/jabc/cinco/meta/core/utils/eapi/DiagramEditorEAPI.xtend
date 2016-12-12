package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.GraphModel
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.editor.DiagramEditor

class DiagramEditorEAPI {
	
	private DiagramEditor editor
	
	new(DiagramEditor editor) {
		this.editor = editor
	}
	
	def static eapi(DiagramEditor editor) {
		new DiagramEditorEAPI(editor)
	}
	
	def getBusinessObject(PictogramElement pe) {
		getBusinessObject(editor, pe)
	}
	
	def static getBusinessObject(DiagramEditor editor, PictogramElement pe) {
		editor.featureProvider?.getBusinessObjectForPictogramElement(pe)
	}

	def getDiagram() {
		getDiagram(editor)
	}

	def static getDiagram(DiagramEditor editor) {
		editor.diagramTypeProvider?.diagram
	}
	
	def getModel() {
		getModel(editor)
	}
	
	def static getModel(DiagramEditor editor) {
		val bo = getBusinessObject(editor, getDiagram(editor))
		if (bo != null && bo instanceof GraphModel)
			bo as GraphModel
		else null
	}
	
	def getFeatureProvider() {
		getFeatureProvider(editor)
	}
	
	def static getFeatureProvider(DiagramEditor editor) {
		editor.diagramTypeProvider?.featureProvider
	}
		
	def getPictogramElement(Object businessObject) {
		getPictogramElement(editor, businessObject)
	}
		
	def static getPictogramElement(DiagramEditor editor, Object businessObject) {
		editor.featureProvider?.getPictogramElementForBusinessObject(businessObject)
	}
	
	def getResourceSet() {
		getResourceSet(editor)
	}
	
	def static getResourceSet(DiagramEditor editor) {
		editor.diagramBehavior?.resourceSet
	}
}