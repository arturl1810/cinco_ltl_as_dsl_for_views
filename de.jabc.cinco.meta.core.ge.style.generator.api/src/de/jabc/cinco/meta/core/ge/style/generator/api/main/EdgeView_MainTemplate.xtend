package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.ge.style.generator.api.templates.EdgeViewTemplate
import mgl.Edge
import mgl.ModelElement

class EdgeView_MainTemplate extends EdgeViewTemplate {

	val Edge e;
	new(ModelElement me) {
		super(me)
		e = me as Edge
	}
	
def doGenerate()
'''package «packageName».api;

public class «e.name»View {
	
	private «e.fqn» viewable;
	
	«e.sourceGetter»
	
	«e.targetGetter»
	
	«e.reconnectSource»
	
	«e.reconnectTarget»
	
	«e.viewableGetter»
	
	«e.viewableSetter»
	
	«e.modelElementGetter»
	
	«e.featureProviderGetter»
	
	«e.diagramGetter»
}

'''
	
}
