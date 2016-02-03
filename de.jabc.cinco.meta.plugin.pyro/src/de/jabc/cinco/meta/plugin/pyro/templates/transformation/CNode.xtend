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

class CNode implements ElementTemplateable{
	
	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.pyro.transformation.api.«graphModel.name.toFirstLower»;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;
import de.ls5.cinco.pyro.transformation.api.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Date;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
public interface C«sme.modelElement.name.toFirstUpper» extends CNode{
	
	
    
    public C«graphModel.name.toFirstUpper» getC«graphModel.name.toFirstUpper»();

    public void setC«graphModel.name.toFirstUpper»(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»);
	
    public String getCName();
    
    public CModelElementContainer getContainer();
    
    public void setContainer(CModelElementContainer container);
    
    «createEdges("Incoming",validConnections,sme)»
    
    «createEdges("Outgoing",validConnections,sme)»
    
    «FOR Attribute attr: sme.modelElement.attributes»
    «CModelElement.createAttribute(attr,sme,enums,graphModel)»
    «ENDFOR»
    «FOR ConnectionConstraint cc: validConnections»
    «IF cc.targetNode.modelElement.name.equals(sme.modelElement.name)»
    «createCessor("Prede",cc.sourceNode)»
    «ENDIF»
    «ENDFOR»
    «FOR ConnectionConstraint cc: validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «createCessor("Suc",cc.targetNode)»
    «ENDIF»
    «ENDFOR»
    
    «FOR ConnectionConstraint cc: validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «createEdge(cc)»
    «ENDIF»
    «ENDFOR»

}
	
	'''
	
	static def createEdges(String prefix,ArrayList<ConnectionConstraint> validConnections,StyledModelElement sme)
	'''
	public List<CEdge> get«prefix.toFirstUpper»();
	'''
	
	static def createEdge(ConnectionConstraint cc)
	'''
	public C«cc.connectingEdge.modelElement.name.toFirstUpper» newC«cc.connectingEdge.modelElement.name.toFirstUpper»(C«cc.targetNode.modelElement.name.toFirstUpper» target);
	'''
	
	static def createCessor(String cessor,StyledNode sn)
	'''
	public List<C«sn.modelElement.name.toFirstUpper»> get«sn.modelElement.name.toFirstUpper»«cessor»cessor();
	'''
	

	
}