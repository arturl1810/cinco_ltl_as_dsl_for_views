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
import mgl.NodeContainer
import java.util.prefs.NodeChangeEvent

class CContainer implements ElementTemplateable{
	
	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.transformation.api.«graphModel.name.toFirstLower»;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;
import de.ls5.cinco.transformation.api.*;

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
	   
	«CNode.createEdges("Incoming",validConnections,sme)»
    
    «CNode.createEdges("Outgoing",validConnections,sme)»
    
    public CModelElementContainer getContainer();
    
    public List<CModelElement> getModelElements();
    
    «FOR StyledNode sn:nodes»
    «IF ModelParser.isContainable(sn.modelElement,sme.modelElement as NodeContainer)»
    «createNewNodes(sn.modelElement)»
    «ENDIF»
    «ENDFOR»

    public void setContainer(CModelElementContainer container);
    «FOR Attribute attr: sme.modelElement.attributes»
    «CModelElement.createAttribute(attr,sme,enums,graphModel)»
    «ENDFOR»

    
    «FOR ConnectionConstraint cc: validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «createNewEdge(cc)»
    «ENDIF»
    «ENDFOR»
	«FOR StyledNode sn:nodes»
    «IF ModelParser.isContainable(sn.modelElement,sme.modelElement as NodeContainer)»
	«createEmbedding(sn.modelElement)»
	«ENDIF»
	«ENDFOR»
}
	
	'''
	
	static def createEmbedding(GraphicalModelElement gme)
	'''
	public void addC«gme.name.toFirstUpper»(C«gme.name.toFirstUpper» node);
	'''
	
	static def createNewEdge(ConnectionConstraint cc)
	'''
	public C«cc.connectingEdge.modelElement.name.toFirstUpper» newC«cc.connectingEdge.modelElement.name.toFirstUpper»(C«cc.targetNode.modelElement.name.toFirstUpper» target);
	'''
	
	static def createNewNodes(GraphicalModelElement gme)
	'''
	«createNewNode(gme)»
	'''
	
	static def createNewNode(mgl.ModelElement gme)
	'''
	public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y);
	
	public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y,long width,long height);
	
	public C«gme.name.toFirstUpper» getC«gme.name.toFirstUpper»(«gme.name.toFirstUpper» «gme.name.toFirstLower»);
	
	
	public List<C«gme.name.toFirstUpper»> getC«gme.name.toFirstUpper»s();
	'''

	
}