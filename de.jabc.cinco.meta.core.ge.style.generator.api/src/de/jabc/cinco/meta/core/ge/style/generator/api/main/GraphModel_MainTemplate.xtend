package de.jabc.cinco.meta.core.ge.style.generator.api.main

import graphicalgraphmodel.impl.CGraphModelImpl
import mgl.GraphModel
import mgl.ModelElement
import de.jabc.cinco.meta.core.ge.style.generator.api.utils.APIUtils

class GraphModel_MainTemplate extends APIUtils{
	
	static var String packageName
	var GraphModel gm
	static var String cname 
	
	new (GraphModel graphModel) {
		this.gm = graphModel
		packageName = graphModel.package 
		cname = getCName(gm as ModelElement)
	}
	
	def create()'''
package «packageName».newcapi;

public class «cname» extends «IF (gm.extends == null)»«CGraphModelImpl.name»«ELSE»«gm.extends.fqcn»«ENDIF»{

	«gm.attributeGetter»
	
	«gm.attributeSetter»
	
	«gm.viewGetter»

}
'''

}
