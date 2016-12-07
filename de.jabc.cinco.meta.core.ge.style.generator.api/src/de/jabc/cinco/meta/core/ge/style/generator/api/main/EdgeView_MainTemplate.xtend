package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.capi.generator.templates.EdgeViewTemplate
import mgl.ModelElement
import mgl.Edge

class EdgeView_MainTemplate extends EdgeViewTemplate {

	val Edge e;
	new(ModelElement me) {
		super(me)
		e = me as Edge
	}
	
def create()
'''package «packageName».newcapi;

public class «e.getCName»View {«««extends «CEdgeViewImpl.name» {
	
	private «e.fqcn» viewable;
	
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
