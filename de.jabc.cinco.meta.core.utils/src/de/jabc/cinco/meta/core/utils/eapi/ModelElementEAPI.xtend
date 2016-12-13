package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.ModelElement

import static extension de.jabc.cinco.meta.core.utils.eapi.EditorPartEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.DiagramEAPI.*

class ModelElementEAPI {
	
	private ModelElement element
	
	new(ModelElement element) {
		this.element = element
	}
	
	def static eapi(ModelElement element) {
		new ModelElementEAPI(element)
	}
	
	def getPictogramElement() {
		getPictogramElement(element)
	}
	
	def static getPictogramElement(ModelElement me) {
		me.eResource.diagram.getPictogramElement(me)
	}
	
	/**
	 * Retrieves the editor this model element is currently edited in, if existent.
	 */
	def getEditor() {
		getEditor(element)
	}
	
	/**
	 * Retrieves the editor this model element is currently edited in, if existent.
	 */
	def static getEditor(ModelElement me) {
		Cinco.Workbench.getEditor(editor | editor.resource == me.eResource)
	}
}