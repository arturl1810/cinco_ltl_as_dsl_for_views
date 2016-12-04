package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import java.util.List
import mgl.Attribute

class CNode implements ElementTemplateable{
	
	override create(StyledModelElement sme, TemplateContainer tc)
	'''
package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;
import de.ls5.cinco.pyro.transformation.api.*;

import java.util.List;
import java.util.List;
import java.util.Date;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
public interface C«sme.modelElement.name.toFirstUpper» extends CNode{
	
	
    
    public C«tc.graphModel.name.toFirstUpper» getC«tc.graphModel.name.toFirstUpper»();

    public void setC«tc.graphModel.name.toFirstUpper»(C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper»);
	
    public String getCName();
    
    public CModelElementContainer getContainer();
    
    public void setContainer(CModelElementContainer container);
    
    «createEdges("Incoming",tc.validConnections,sme)»
    
    «createEdges("Outgoing",tc.validConnections,sme)»
    
    «FOR Attribute attr: sme.modelElement.attributes»
	    «CModelElement.createAttribute(attr,sme,tc.enums,tc.graphModel)»
    «ENDFOR»
    «FOR ConnectionConstraint cc: tc.validConnections»
	    «IF cc.targetNode.modelElement.name.equals(sme.modelElement.name)»
	    	«createCessor("Prede",cc.sourceNode)»
	    «ENDIF»
    «ENDFOR»
    «FOR ConnectionConstraint cc: tc.validConnections»
	    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
	    	«createCessor("Suc",cc.targetNode)»
	    «ENDIF»
    «ENDFOR»
    
    «FOR ConnectionConstraint cc: tc.validConnections»
	    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
	    	«createEdge(cc)»
	    «ENDIF»
    «ENDFOR»

}
	
	'''
	
	static def createEdges(String prefix,List<ConnectionConstraint> validConnections,StyledModelElement sme)
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