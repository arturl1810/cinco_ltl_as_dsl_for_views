package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import org.eclipse.emf.ecore.resource.Resource.Factory
import org.eclipse.emf.common.util.URI
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl

class GraphitiResourceFactory {
	
	extension APIUtils = new APIUtils
	
	def generateResourceFactory(GraphModel gm)'''
	package «gm.packageName»
	
	import org.eclipse.emf.ecore.resource.Resource.Factory
	
	class «gm.fuName»APIParser implements «Factory.name» {
		new() {
		}
	
		override Resource createResource(«URI.name» uri) {
			return new «gm.fuName»ApiResouce(uri)
		} 
	}
	
	class GraphitiApiResouce extends «XMIResourceImpl.name» {
		
		new() {
			super()
		}
	
		new(URI uri) {
			super(uri)
		}
	
	
		override protected getEObjectByID(«String.name» id) {
			val obj = super.getEObjectByID(id)
			switch (obj) {
				«InternalGraphModel.name»: obj.createAndUpdateGraphitiApiElement
				«InternalModelElement.name»: obj.createAndUpdateGraphitiApiElement
			}
			obj
		}
		
		def createAndUpdateGraphitiApiElement(«InternalGraphModel.name» it) {
			switch (it) {
				«gm.fqInternalBeanName»: element = new «gm.fqCName»()
			}
		}
		
		def createAndUpdateGraphitiApiElement(«InternalModelElement.name» it) {
			val pe = getLinkedPictogramElement
			switch (it) {
				«FOR me : gm.modelElements»
				«me.fqInternalName» : {
					var cElement = new «me.fqCName»()
					cElement.pictogramElement = pe
				}
				«ENDFOR»
			}
		}
		
		def getLinkedPictogramElement(«InternalModelElement.name» it) {
			var d = this.getContent(«Diagram.name»)
			d.fetchLinkedElement(it)
		}
		
		def fetchLinkedElement(«Diagram.name» d, «InternalModelElement.name» me) {
			val head = d.pictogramLinks.filter[businessObjects.contains(me)].head.pictogramElement
			head
		}
	}
	'''
	
}