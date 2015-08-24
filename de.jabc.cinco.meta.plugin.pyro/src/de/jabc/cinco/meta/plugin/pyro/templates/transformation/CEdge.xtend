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
    «CModelElement.createAttribute(attr,sme,enums,graphModel)»
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