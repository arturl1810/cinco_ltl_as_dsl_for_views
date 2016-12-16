package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.ge.style.generator.api.templates.GraphModelViewTemplate
import mgl.ContainingElement
import mgl.GraphModel

class GraphModelView_MainTemplate extends GraphModelViewTemplate{

	var GraphModel gm

	new(GraphModel gm) {
		super(gm)
		this.gm = gm
	}
	
	def doGenerate()'''
	package «gm.package».api;

	public class «gm.name»View {
	
		private «gm.fqn» viewable;

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
