package de.jabc.cinco.meta.core.ge.style.generator.api.main

import graphicalgraphmodel.impl.CEdgeImpl
import mgl.Edge

class Edge_MainTemplate extends de.jabc.cinco.meta.core.capi.generator.ModelElement_MainTemplate {
	
	Edge e
	
	new (Edge edge) {
		super(edge)
		e = edge
	}
	
	def create() '''
package «packageName».newcapi;
	
public class C«fuMEName» extends «IF (e.extends == null)»«CEdgeImpl.name»«ELSE»«e.extends.fqcn»«ENDIF»{

	«e.attributeGetter»
	
	«e.attributeSetter»

	«e.viewGetter»
}
'''
		
}
