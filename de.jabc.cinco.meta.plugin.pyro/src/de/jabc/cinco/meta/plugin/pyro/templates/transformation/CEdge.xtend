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

class CEdge implements ElementTemplateable{
	
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
public interface C«sme.modelElement.name.toFirstUpper» extends CEdge{
	
	public C«graphModel.name.toFirstUpper» getC«graphModel.name.toFirstUpper»();

    public void setC«graphModel.name.toFirstUpper»(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»);
	
    public String getCName();
    «FOR Attribute attr: sme.modelElement.attributes»
    «createAttribute(attr,sme)»
    «ENDFOR»
    
    public CNode getSourceElement();
    
    public void reconnectSource(CNode cNode);

    public void reconnectTarget(CNode cNode);

    public CNode getTargetElement();
    public CModelElementContainer getContainer();
    
    public void setContainer(CModelElementContainer container);
    
    public void addBendingPoint(long x,long y);

    public void addBendingPoint(CBendingpoint bendingpoint);
    
    public void removeAllBendingPoints();
    
    public void setBendingPoints(List<CBendingpoint> bendingPoints);

    public void setEdge(«sme.modelElement.name.toFirstUpper» edge);

    public «sme.modelElement.name.toFirstUpper» getEdge();

}
	
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