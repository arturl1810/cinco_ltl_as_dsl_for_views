package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import java.util.ArrayList
import mgl.Attribute
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import mgl.ModelElement

class CModelElementImpl {
	
	static def createCommadsGetters(ModelElement modelElement,String type)
	'''
	public PyroRemove«type.toFirstUpper»CommandController getPyroCreate«type.toFirstUpper»CommandController(){
		return this.pyroRemove«type.toFirstUpper»CommandController;
	}
	
	public PyroCreate«type.toFirstUpper»CommandController getPyroCreate«type.toFirstUpper»CommandController(){
		return this.pyroCreate«type.toFirstUpper»CommandController;
	}
	
	
	'''
	
	static def createCommadsAttrs(ModelElement modelElement,String type)
	'''
	@Inject
	private PyroRemove«type.toFirstUpper»CommandController pyroCreate«type.toFirstUpper»CommandController;
	@Inject
	private PyroCreate«type.toFirstUpper»CommandController pyroCreate«type.toFirstUpper»CommandController;
	
	
	'''
	
	static def createNodeCommandsGetters(mgl.Node node)
	'''
	«createCommadsGetters(node,"Node")»
	
	public PyroMoveNodeCommandController getPyroMoveNodeCommandController(){
		return this.pyroMoveNodeCommandController;
	}
	
	public PyroResizeNodeommandController getPyroResizeNodeCommandController(){
		return this.pyroResizeNodeCommandController;
	}
	
	public PyroRotateNodeCommandController getPyroRotateNodeCommandController(){
		return this.pyroRemoveNodeCommandController;
	}
	'''
	
	static def createNodeCommandsAttrs(mgl.Node node)
	'''
	«createCommadsAttrs(node,"Node")»
	@Inject
	private PyroMoveNodeCommandController pyroMoveNodeCommandController;
	@Inject
	private PyroResizeNodeommandController pyroResizeNodeCommandController;
	@Inject
	private PyroRotateNodeCommandController pyroRotateNodeCommandController;
	'''
	
	static def createEdgeCommandsAttrs(mgl.Edge edge)
	'''
	«createCommadsAttrs(edge,"Edge")»
	@Inject
	private PyroReconnectEdgeCommandController pyroReconnectEdgeCommandController;
	@Inject
	private PyroVertexEdgeCommandController pyroVertexEdgeCommandController;
	@Inject
	private PyroRotateNodeCommandController pyroRotateNodeCommandController;
	'''
	
	static def createEdgeCommandsGetters(mgl.Edge edge)
	'''
	«createCommadsGetters(edge,"Edge")»
	public PyroReconnectEdgeCommandController getPyroReconnectEdgeCommandController(){
		return this.pyroReconnectEdgeCommandController;
	}

	public PyroVertexEdgeCommandController pyroVertexEdgeCommandController(){
		return this.pyroVertexEdgeCommandController;
	}
	public PyroRotateNodeCommandController pyroRotateNodeCommandController(){
		return this.pyroRotateNodeCommandController;
	}
	'''
	
	static def createAttribute(mgl.Attribute attribute,StyledModelElement sme,ArrayList<mgl.Type> enums)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,sme.modelElement,enums)»
	«ELSE»
	«createListAttribute(attribute,sme.modelElement,enums)»
	«ENDIF»
	
	'''
	
	static def createAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,sme,enums)»
	«ELSE»
	«createListAttribute(attribute,sme,enums)»
	«ENDIF»
	
	'''
	
	
	static def createPrimativeAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums)
	'''
	public «getAttributeType(attribute,enums)» get«attribute.name.toFirstUpper»(){
		return ((«sme.name.toFirstUpper»)this.modelElement).get«attribute.name.toFirstLower»();
	}
	
	public void set«attribute.name.toFirstUpper»(«getAttributeType(attribute,enums)» «attribute.name.toFirstLower») {
	    ((«sme.name.toFirstUpper»)this.modelElement).set«attribute.name.toFirstLower»(«attribute.name.toFirstLower»);
	}
	'''
	
	static def createListAttribute(mgl.Attribute attribute,mgl.ModelElement sme,ArrayList<mgl.Type> enums)
	'''
	public List<«getAttributeType(attribute,enums)»> get«attribute.name.toFirstUpper»(){
		«IF ModelParser.isUserDefinedType(attribute,enums)»
		return ((«sme.name.toFirstUpper»)this.modelElement).get«attribute.name.toFirstLower»_«attribute.type.toFirstUpper»Type();
		«ELSE»
		return ((«sme.name.toFirstUpper»)this.modelElement).get«attribute.name.toFirstLower»();
		«ENDIF»
	}
	
	public void set«attribute.name.toFirstUpper»(List<«getAttributeType(attribute,enums)»> «attribute.name.toFirstLower») {
		«IF ModelParser.isUserDefinedType(attribute,enums)»
		((«sme.name.toFirstUpper»)this.modelElement).get«attribute.name.toFirstLower»_«attribute.type.toFirstUpper»Type().clear();
		((«sme.name.toFirstUpper»)this.modelElement).get«attribute.name.toFirstLower»_«attribute.type.toFirstUpper»Type().addAll(«attribute.name.toFirstLower»);
		«ELSE»
	    ((«sme.name.toFirstUpper»)this.modelElement).set«attribute.name.toFirstLower»(«attribute.name.toFirstLower»);
	    «ENDIF»
	}
	'''
	
	static def getAttributeType(Attribute attribute,ArrayList<mgl.Type> enums) {
	if(attribute.type.equals("EString")) return "String";
	if(attribute.type.equals("EInt")) return "long";
	if(attribute.type.equals("EDouble")) return "double";
	if(attribute.type.equals("EBoolean")) return "boolean";
	if(ModelParser.isUserDefinedType(attribute,enums)){
		return attribute.type+"Type";
	}
	//ENUM
	return "String";
	
}
}