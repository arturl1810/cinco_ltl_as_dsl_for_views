package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.capi.generator.templates.GraphModelViewTemplate
import mgl.GraphModel

class GraphModelView_MainTemplate extends GraphModelViewTemplate{

	var GraphModel gm

	new(GraphModel gm) {
		super(gm)
		this.gm = gm
	}
	
	def create()'''
	package «gm.package».newcapi;

	public class «getCName(gm as mgl.ContainingElement)»View {
	
		private «gm.fqcn» viewable;

		«gm.attributeGetter»
	
		«gm.attributeSetter»
	
		«gm.viewableGetter»
	
		«gm.viewableSetter»
	
		«gm.modelElementGetter»
	
		«gm.featureProviderGetter»
		
		«gm.diagramGetter»
		
		«FOR posNode : gm.getContainableNodes»
		«gm.canNewMethod(posNode)»
		«gm.newNodeMethod(posNode)»
		«ENDFOR»
	
	}
'''

}
