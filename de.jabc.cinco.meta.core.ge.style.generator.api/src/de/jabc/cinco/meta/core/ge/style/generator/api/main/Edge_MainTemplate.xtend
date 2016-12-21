package de.jabc.cinco.meta.core.ge.style.generator.api.main

import graphicalgraphmodel.impl.CEdgeImpl
import mgl.Edge

class Edge_MainTemplate extends ModelElement_MainTemplate {
	
	Edge e
	
	new (Edge edge) {
		super(edge)
		e = edge
	}
	
	def doGenerate() '''
package «packageName».api;
	
public class «fuMEName» extends «IF (e.extends == null)»«CEdgeImpl.name»«ELSE»«e.extends.fqn»«ENDIF»{

	«e.attributeGetter»
	
	«e.attributeSetter»

	«e.viewGetter»
}
'''
		
}
