package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import org.eclipse.emf.ecore.resource.Resource.Factory
import org.eclipse.emf.common.util.URI
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.emf.ecore.resource.Resource
import graphmodel.IdentifiableElement

class GraphitiResourceFactory {
	
	extension APIUtils = new APIUtils
	
	def generateResourceFactory(GraphModel gm)'''
	package «gm.packageName»
	
	import org.eclipse.emf.ecore.resource.Resource.Factory
	
	class «gm.fuName»APIParser implements «Factory.name» {
		new() {
		}
	
		override «Resource.name» createResource(«URI.name» uri) {
			return new «gm.fuName»ApiResouce(uri)
		} 
	}
	
	class «gm.fuName»ApiResouce extends «XMIResourceImpl.name» {
		
		new() {
			super()
		}
	
		new(«URI.name» uri) {
			super(uri)
		}
	
	
		override protected getEObjectByID(«String.name» id) {
			val obj = super.getEObjectByID(id)
			switch (obj) {
				«IdentifiableElement.name»: obj.createAndUpdateGraphitiApiElement
			}
			obj
		}
		
		def createAndUpdateGraphitiApiElement(«IdentifiableElement.name» it) {
			val pe = getLinkedPictogramElement
			switch (it) {
				«FOR me : gm.modelElements»
				«me.fqInternalName» : {
					var cElement = new «me.fqCName»()
					cElement.pictogramElement = pe
					it.element = cElement
«««					new «me.fqCName»()
				}
				«ENDFOR»
			}
			it
		}
		
		def getLinkedPictogramElement(«IdentifiableElement.name» it) {
			val conts = getContents
			val d = conts.get(0) as «Diagram.name»;
			if (it instanceof «InternalGraphModel.name»)
				return d;
			d.fetchLinkedElement(it)
		}
		
		def fetchLinkedElement(«Diagram.name» d, «IdentifiableElement.name» me) {
			d.pictogramLinks?.filter[businessObjects.contains(me)].head?.pictogramElement
		}
	}
	'''
	
}