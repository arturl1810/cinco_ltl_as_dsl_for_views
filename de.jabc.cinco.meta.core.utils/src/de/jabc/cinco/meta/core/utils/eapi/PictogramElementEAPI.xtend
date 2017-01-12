package de.jabc.cinco.meta.core.utils.eapi

import org.eclipse.graphiti.mm.pictograms.PictogramElement

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workbench.*

import static extension de.jabc.cinco.meta.core.utils.eapi.EditorPartEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.DiagramEditorEAPI.*

class PictogramElementEAPI {
	
	private PictogramElement pe
	
	new(PictogramElement pe) {
		this.pe = pe
	}
	
	def static eapi(PictogramElement pe) {
		new PictogramElementEAPI(pe)
	}
	
	def getBusinessObject() {
		getBusinessObject(pe)
	}
	
	def static getBusinessObject(PictogramElement pe) {
		diagramEditor?.getBusinessObject(pe)
	}
	
	def boolean testBusinessObjectType(Class<?> cls) {
		testBusinessObjectType(pe, cls)
	}
	
	def static testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		val bo = pe.businessObject
		return bo != null && cls.isAssignableFrom(bo.class)
	}
	
	def refreshDecorators() {
		refreshDecorators(pe)
	}
	
	def static refreshDecorators(PictogramElement pe) {
		async[| diagramBehavior?.refreshRenderingDecorators(pe) ]
	}
	
	/**
	 * Retrieves the editor this pictogram is currently edited in, if existent.
	 */
	def getEditor() {
		getEditor(pe)
	}
	
	/**
	 * Retrieves the editor this pictogram is currently edited in, if existent.
	 */
	def static getEditor(PictogramElement pe) {
		Cinco.Workbench.getEditor(editor | editor.resource == pe.eResource)
	}
}