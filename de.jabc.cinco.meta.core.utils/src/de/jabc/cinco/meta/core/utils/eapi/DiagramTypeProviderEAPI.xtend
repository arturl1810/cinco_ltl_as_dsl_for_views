package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.GraphModel
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.editor.DiagramBehavior

class DiagramTypeProviderEAPI {
	
	private IDiagramTypeProvider dtp
	
	new(IDiagramTypeProvider dtp) {
		this.dtp = dtp
	}
	
	def static eapi(IDiagramTypeProvider dtp) {
		new DiagramTypeProviderEAPI(dtp)
	}
	
	def getBusinessObject(PictogramElement pe) {
		getBusinessObject(dtp, pe)
	}
	
	def static getBusinessObject(IDiagramTypeProvider dtp, PictogramElement pe) {
		dtp.featureProvider?.getBusinessObjectForPictogramElement(pe)
	}
	
	def getModel() {
		getModel(dtp)
	}
	
	def static getModel(IDiagramTypeProvider dtp) {
		val bo = getBusinessObject(dtp, dtp.diagram)
		if (bo != null && bo instanceof GraphModel)
			bo as GraphModel
		else null
	}
	
	def getResourceSet() {
		getResourceSet(dtp)
	}
	
	def static getResourceSet(IDiagramTypeProvider dtp) {
		val Object db = dtp.diagramBehavior
		if (db != null && db instanceof DiagramBehavior)
			(db as DiagramBehavior).resourceSet
		else null
	}
}