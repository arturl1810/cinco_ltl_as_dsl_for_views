package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.capi.generator.utils.CAPIUtils
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node

class ModelElement_MainTemplate extends CAPIUtils {
	
	protected GraphModel gm
	protected ModelElement me
	protected String packageName
	protected String fuMEName
	
	new(ModelElement me) {
		this.me = me
		switch me {
			Node : gm = me.rootElement	
			Edge : gm = me.rootElement
			}
		packageName = gm.package
		fuMEName = me.name.toFirstUpper
	}
	
}
