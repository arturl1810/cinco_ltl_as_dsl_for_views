package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import java.util.ArrayList
import mgl.Attribute
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class CModelElement {
	static def createAttribute(mgl.Attribute attribute,StyledModelElement sme,ArrayList<mgl.Type> enums,mgl.GraphModel graphModel)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,sme.modelElement,enums,graphModel)»
	«ELSE»
	«createListAttribute(attribute,sme.modelElement,enums,graphModel)»
	«ENDIF»
	
	'''
	
	static def createAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums,mgl.GraphModel graphModel)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,sme,enums,graphModel)»
	«ELSE»
	«createListAttribute(attribute,sme,enums,graphModel)»
	«ENDIF»
	
	'''
	
	static def createPrimativeAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums,mgl.GraphModel graphModel)
	'''
	public «getAttributeType(attribute,enums,graphModel)» get«attribute.name.toFirstUpper»();
	
	public void set«attribute.name.toFirstUpper»(«getAttributeType(attribute,enums,graphModel)» «attribute.name.toFirstLower»);
	'''
	
	static def createListAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums,mgl.GraphModel graphModel)
	'''
	«IF ModelParser.isUserDefinedType(attribute,enums)»
	public List<«getAttributeType(attribute,enums,graphModel)»> get«attribute.name.toFirstUpper»();
	
	public void set«attribute.name.toFirstUpper»(List<«getAttributeType(attribute,enums,graphModel)»> «attribute.name.toFirstLower»);
	«ELSE»
	public List<String> get«attribute.name.toFirstUpper»();
	
	public void set«attribute.name.toFirstUpper»(List<String> «attribute.name.toFirstLower»);
	«ENDIF»
	'''
	
	static def getAttributeType(Attribute attribute,ArrayList<mgl.Type> enums,mgl.GraphModel graphModel) {
	if(attribute.type.equals("EString")) return "String";
	if(attribute.type.equals("EInt")) return "long";
	if(attribute.type.equals("EDouble")) return "double";
	if(attribute.type.equals("EBoolean")) return "boolean";
	if(ModelParser.isUserDefinedType(attribute,enums)){
		return attribute.type+"Type";
	}
	if(ModelParser.isReferencedModelType(graphModel,attribute)){
		return attribute.type;
	}
	//ENUM
	return "String";
	
	}
	
	
	static def createCommadsGetters(mgl.ModelElement modelElement,String type)
	'''
	public PyroRemove«type.toFirstUpper»CommandController getPyroCreate«type.toFirstUpper»CommandController();
	
	public PyroCreate«type.toFirstUpper»CommandController getPyroCreate«type.toFirstUpper»CommandController();
	
	
	'''
	
	
	static def createNodeCommandsGetters(mgl.Node node)
	'''
	«createCommadsGetters(node,"Node")»
	
	public PyroMoveNodeCommandController getPyroMoveNodeCommandController();
	
	public PyroResizeNodeommandController getPyroResizeNodeCommandController();
	
	public PyroRotateNodeCommandController getPyroRotateNodeCommandController();
	'''

	
	static def createEdgeCommandsGetters(mgl.Edge edge)
	'''
	«createCommadsGetters(edge,"Edge")»
	public PyroReconnectEdgeCommandController getPyroReconnectEdgeCommandController();

	public PyroVertexEdgeCommandController pyroVertexEdgeCommandController();
	public PyroRotateNodeCommandController pyroRotateNodeCommandController(); 
	'''
}