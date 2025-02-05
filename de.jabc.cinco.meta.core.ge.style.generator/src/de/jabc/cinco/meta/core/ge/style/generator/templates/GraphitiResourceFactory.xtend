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
import de.jabc.cinco.meta.runtime.contentadapter.CincoEContentAdapter
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Shape

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
			val ie = internalElement
			switch (ie) {
				«FOR me : gm.modelElements.filter[!isIsAbstract]»
				«me.fqInternalName» : {
					var cElement =	if (it instanceof «me.fqCName»)
										it as «me.fqCName»
									else new «me.fqCName»
					cElement.pictogramElement = pe as «me.pictogramElementReturnType»
					ie.element = cElement
					if (!ie.eAdapters.exists[it instanceof «me.packageNameEContentAdapter».«me.fuName»EContentAdapter])
						ie.eAdapters.add(new «me.packageNameEContentAdapter».«me.fuName»EContentAdapter)
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
			var pe = d.pictogramLinks?.filter[businessObjects.contains(me)].head?.pictogramElement
			if (pe === null) 
				pe = d.getPes.filter[link?.businessObjects?.contains(me)].head
			if (pe === null)
				pe = d.connections.filter[link?.businessObjects?.contains(me)].head
			pe
		}
		
		private def Iterable<«Shape.name»> getPes(«ContainerShape.name» cs) {
			return cs.children + cs.children.filter(«ContainerShape.name»).map[getPes].flatten
		}
	}
	'''
	
}