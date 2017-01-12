package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import mgl.Attribute

class CEdge implements ElementTemplateable{
	
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
		public interface C«sme.modelElement.name.toFirstUpper» extends CEdge{
			
			public C«tc.graphModel.name.toFirstUpper» getC«tc.graphModel.name.toFirstUpper»();
		
		    public void setC«tc.graphModel.name.toFirstUpper»(C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper»);
			
		    public String getCName();
		    «FOR Attribute attr: sme.modelElement.attributes»
		    «CModelElement.createAttribute(attr,sme,tc.enums,tc.graphModel)»
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
}