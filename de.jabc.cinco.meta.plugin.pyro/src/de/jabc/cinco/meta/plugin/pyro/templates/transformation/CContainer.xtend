package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import mgl.Attribute
import mgl.GraphicalModelElement
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class CContainer implements ElementTemplateable{
	
	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
public interface C«sme.modelElement.name.toFirstUpper» extends CContainer{
	
    
    public C«graphModel.name.toFirstUpper» getC«graphModel.name.toFirstUpper»();

    public void setC«graphModel.name.toFirstUpper»(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»);
	
	
    public String getCName();
    public void moveTo(final C«graphModel.name.toFirstUpper» container, long x, long y);
	public C«sme.modelElement.name.toFirstUpper» clone(C«graphModel.name.toFirstUpper» target);
	   
	«createEdges("Incoming",validConnections,sme)»
    
    «createEdges("Outgoing",validConnections,sme)»
    
    public CModelElementContainer getContainer();
    
    public List<CModelElement> getModelElements();
    
    «FOR EmbeddingConstraint ec:embeddingConstraints»
    «IF ec.container.name.equals(sme.modelElement.name)»
    «createNewNode(ec)»
    
    «ENDIF»
    «ENDFOR»

    public void setContainer(CModelElementContainer container);
    «FOR Attribute attr: sme.modelElement.attributes»
    «createAttribute(attr,sme)»
    «ENDFOR»

    
    «FOR ConnectionConstraint cc: validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «createNewEdge(cc)»
    «ENDIF»
    «ENDFOR»
	«FOR EmbeddingConstraint ec : embeddingConstraints»
	«IF ec.container.name.equals(sme.modelElement.name)»
	«FOR GraphicalModelElement gme:ec.validNode»
	«createEmbedding(gme)»
	«ENDFOR»
	«ENDIF»
	«ENDFOR»
}
	
	'''
	
	def createEdges(String prefix,ArrayList<ConnectionConstraint> validConnections,StyledModelElement sme)
	'''
    public List<CEdge> get«prefix.toFirstUpper»();
	'''
	
	def createEmbedding(GraphicalModelElement gme)
	'''
	public void addC«gme.name.toFirstUpper»(C«gme.name.toFirstUpper» node);
	'''
	
	def createNewEdge(ConnectionConstraint cc)
	'''
	public C«cc.connectingEdge.modelElement.name.toFirstUpper» newC«cc.connectingEdge.modelElement.name.toFirstUpper»(C«cc.targetNode.modelElement.name.toFirstUpper» target);
	'''
	
	def createNewNode(EmbeddingConstraint ec)
	'''
	«FOR GraphicalModelElement gme:ec.validNode»
	public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y);
	
	public C«gme.name.toFirstUpper» getC«gme.name.toFirstUpper»(«gme.name.toFirstUpper» «gme.name.toFirstLower»);
	
	public List<C«gme.name.toFirstUpper»> getC«gme.name.toFirstUpper»s();
	
	«ENDFOR»
	'''
	
	
	def createCessor(String cessor,StyledNode sn)
	'''
	public List<C«sn.modelElement.name.toFirstUpper»> get«sn.modelElement.name.toFirstUpper»«cessor»cessor();
	'''
	
	def createAttribute(mgl.Attribute attribute,StyledModelElement sme)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,sme)»
	«ELSE»
	«createListAttribute(attribute,sme)»
	«ENDIF»
	
	'''
	
	def createPrimativeAttribute(mgl.Attribute attribute,StyledModelElement sme)
	'''
	public «getAttributeType(attribute.type)» get«attribute.name.toFirstUpper»();
	
	public void set«attribute.name.toFirstUpper»(«getAttributeType(attribute.type)» «attribute.name.toFirstLower»);
	'''
	
	def createListAttribute(mgl.Attribute attribute,StyledModelElement sme)
	'''
	public List<String> get«attribute.name.toFirstUpper»();
	
	public void set«attribute.name.toFirstUpper»(List<String> «attribute.name.toFirstLower»);
	'''
	
	def getAttributeType(String type) {
	if(type.equals("EString")) return "String";
	if(type.equals("EInt")) return "long";
	if(type.equals("EDouble")) return "double";
	if(type.equals("EBoolean")) return "boolean";
	//ENUM
	return "String";
}

	
}