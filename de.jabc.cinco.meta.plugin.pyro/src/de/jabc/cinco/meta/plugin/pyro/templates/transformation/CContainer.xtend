package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import mgl.Attribute
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.NodeContainer

class CContainer implements ElementTemplateable{
	
	override create(StyledModelElement sme, TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
		import de.ls5.dywa.generated.entity.*;
		import de.ls5.dywa.generated.controller.*;
		import de.ls5.cinco.pyro.transformation.api.*;
		
		import java.util.ArrayList;
		import java.util.List;
		
		/**
		 * Created by Pyro CINCO Meta Plugin.
		 */
		public interface C«sme.modelElement.name.toFirstUpper» extends CContainer{
			
		    
		    public C«tc.graphModel.name.toFirstUpper» getC«tc.graphModel.name.toFirstUpper»();
		
		    public void setC«tc.graphModel.name.toFirstUpper»(C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper»);
			
		    public String getCName();
		    public void moveTo(final C«tc.graphModel.name.toFirstUpper» container, long x, long y);
			public C«sme.modelElement.name.toFirstUpper» clone(C«tc.graphModel.name.toFirstUpper» target);
			   
			«CNode.createEdges("Incoming",tc.validConnections,sme)»
		    
		    «CNode.createEdges("Outgoing",tc.validConnections,sme)»
		    
		    public CModelElementContainer getContainer();
		    
		    public List<CModelElement> getModelElements();
		    
		    «FOR StyledNode sn:tc.nodes.filter[sn|ModelParser.isContainable(sn.modelElement,sme.modelElement as NodeContainer)]»
			    «createNewNodes(sn.modelElement)»
		    «ENDFOR»
		
		    public void setContainer(CModelElementContainer container);
		    «FOR Attribute attr: sme.modelElement.attributes»
		    	«CModelElement.createAttribute(attr,sme,tc.enums,tc.graphModel)»
		    «ENDFOR»
		
		    
		    «FOR ConnectionConstraint cc: tc.validConnections.filter[cc|cc.sourceNode.modelElement.name.equals(sme.modelElement.name)]»
			    «createNewEdge(cc)»
		    «ENDFOR»
			«FOR StyledNode sn:tc.nodes.filter[sn|ModelParser.isContainable(sn.modelElement,sme.modelElement as NodeContainer)]»
				«createEmbedding(sn.modelElement)»
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
	
	static def createNewNode(ModelElement gme)
	'''
		public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y);
		
		public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y,long width,long height);
		
		public C«gme.name.toFirstUpper» getC«gme.name.toFirstUpper»(«gme.name.toFirstUpper» «gme.name.toFirstLower»);
		
		
		public List<C«gme.name.toFirstUpper»> getC«gme.name.toFirstUpper»s();
	'''	
}