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
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import org.eclipse.emf.ecore.EClass
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import mgl.ReferencedType

class CGraphModel implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
public interface C«graphModel.name.toFirstUpper» extends CGraphModel{
	
    public String getCName();
    
    @Override
    public List<CModelElement> getModelElements();
    
    «FOR StyledNode sn:nodes»
    public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller();
    
    public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController();
    
    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id);
    «ENDFOR»
    
    «FOR StyledEdge sn:edges»
    public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller();
    
    public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController();
    
    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower»);
    
    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id);
    «ENDFOR»
    
    «FOR ReferencedType primeRef : ModelParser.getPrimeReferencedModelElements(graphModel)»
    public «primeRef.type.name.toFirstUpper»PrimeController get«primeRef.type.name.toFirstUpper»PrimeController();
    «ENDFOR»
    
    public PyroMoveNodeCommandController getPyroMoveNodeCommandController();
	
	public PyroResizeNodeCommandController getPyroResizeNodeCommandController();
	
	public PyroRotateNodeCommandController getPyroRotateNodeCommandController();
	
	public PyroReconnectEdgeCommandController getPyroReconnectEdgeCommandController();

	public PyroVertexEdgeCommandController pyroVertexEdgeCommandController();
	
	public PyroRotateNodeCommandController pyroRotateNodeCommandController(); 
	
	public PyroRemoveNodeCommandController getPyroRemoveNodeCommandController();
	
	public PyroCreateNodeCommandController getPyroCreateNodeCommandController();
	
	public PyroRemoveEdgeCommandController getPyroRemoveEdgeCommandController();
	
	public PyroCreateEdgeCommandController getPyroCreateEdgeCommandController();
    
    public PointController getPointController();

    public void setPointController(PointController pointController);
    
    «FOR StyledNode sn:nodes»
    «CContainer.createNewNode(sn.modelElement)»
    «ENDFOR»

    «FOR Attribute attr: graphModel.attributes»
    «CModelElement.createAttribute(attr,graphModel,enums,graphModel)»
    «ENDFOR»
}
	
	'''
	
}