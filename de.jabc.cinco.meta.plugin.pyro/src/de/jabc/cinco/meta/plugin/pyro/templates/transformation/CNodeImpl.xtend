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
import mgl.GraphicalElementContainment
import mgl.NodeContainer

class CNodeImpl implements ElementTemplateable{
	
	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.pyro.transformation.api.«graphModel.name.toFirstLower»;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;
import de.ls5.cinco.pyro.transformation.api.*;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
public class C«sme.modelElement.name.toFirstUpper»Impl implements C«sme.modelElement.name.toFirstUpper»{
	
	protected «sme.modelElement.name.toFirstUpper» modelElement;
	
	protected C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»;

    
    public C«graphModel.name.toFirstUpper» getC«graphModel.name.toFirstUpper»() {
        return c«graphModel.name.toFirstUpper»;
    }

    public void setC«graphModel.name.toFirstUpper»(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper») {
        this.c«graphModel.name.toFirstUpper» = c«graphModel.name.toFirstUpper»;
    }
    
	
    public String getCName(){
        return "«sme.modelElement.name.toFirstUpper»";
    }
    
    @Override
    public CModelElementContainer getContainer() {
    	if(modelElement.getcontainer() instanceof «graphModel.name.toFirstUpper»){
            return this.c«graphModel.name.toFirstUpper»;
        }
        «FOR StyledNode sn:nodes»
        «IF sn.modelElement instanceof NodeContainer»
		«IF ModelParser.isContainable(sme.modelElement,sn.modelElement as NodeContainer)»
        if(modelElement.getcontainer() instanceof «sn.modelElement.name.toFirstUpper»){
            C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
            c«sn.modelElement.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this.c«graphModel.name.toFirstUpper»);
            c«sn.modelElement.name.toFirstUpper».setModelElementContainer(modelElement.getcontainer());
            return c«sn.modelElement.name.toFirstUpper»;
        }
        «ENDIF»
        «ENDIF»
        «ENDFOR»
    	return null;
    }
    
    @Override
    public void setContainer(CModelElementContainer container) {
        //COMMAND EMBEDD
        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
        this.modelElement.setcontainer(container.getModelElementContainer());
        container.getModelElementContainer().getmodelElements_ModelElement().add(this.modelElement);
    }
    
    «createEdges("Incoming",validConnections,sme,graphModel.name)»
    
    «createEdges("Outgoing",validConnections,sme,graphModel.name)»
    
    «FOR Attribute attr: sme.modelElement.attributes»
    «CModelElementImpl.createAttribute(attr,sme,enums,graphModel)»
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
    «createEdge(cc,graphModel.name)»
    «ENDIF»
    «ENDFOR»
    
    public List<CNode> getSuccessors(){
        List<CNode> cNodes = getOutgoing().stream().map(CEdge::getTargetElement).collect(Collectors.toList());
        return  cNodes;
    }

    public <T extends CNode> List<T> getSuccessors(Class<T> clazz) {
        List<T> list = getSuccessors().stream().filter(cNode -> clazz.isInstance(cNode)).map(cNode -> (T) cNode).collect(Collectors.toList());
        return list;
    }

    public List<CNode> getPredecessors(){
        List<CNode> cNodes = getIncoming().stream().map(CEdge::getSourceElement).collect(Collectors.toList());
        return  cNodes;
    }

    public <T extends CNode> List<T> getPredecessors(Class<T> clazz) {
        List<T> list = getPredecessors().stream().filter(cNode -> clazz.isInstance(cNode)).map(cNode -> (T) cNode).collect(Collectors.toList());
        return list;
    }

    public <T extends CEdge> List<T> getIncoming(Class<T> clazz) {
        List<T> list = getIncoming().stream().filter(cEdge -> clazz.isInstance(cEdge)).map(cEdge -> (T) cEdge).collect(Collectors.toList());
        return list;
    }

    public <T extends CEdge> List<T> getOutgoing(Class<T> clazz) {
        List<T> list = getOutgoing().stream().filter(cEdge -> clazz.isInstance(cEdge)).map(cEdge -> (T) cEdge).collect(Collectors.toList());
        return list;
    }

    public long getX(){
        return modelElement.getposition().getx();
    }

    public long getY(){
        return modelElement.getposition().gety();
    }

    public long getWidth(){
        return modelElement.getwidth();
    }

    public long getHeight(){
        return modelElement.getheight();
    }

    public void setX(long x){
        moveTo(x,getY());
    }

    public void setY(long y){
        moveTo(getX(),y);
    }

    public void setWidth(long width){
        resize(width,getHeight());
    }

    public void setHeight(long height){
        resize(getWidth(),height);
    }

    public void moveTo(long x,long y){
        //MOVE COMMAND
        this.modelElement.getposition().setx(x);
        this.modelElement.getposition().sety(y);
    }

    public void resize(long width,long height) {
        //RESIZE COMMAND
        this.modelElement.setwidth(width);
        this.modelElement.setheight(height);
    }

    public void setAngle(double angle){
        //ROTATE COMMAND
        this.modelElement.setangle(angle);
    }

    public double getAngle(){
        return this.modelElement.getangle();
    }

    public void rotate(double degrees){
        setAngle(getAngle()+degrees);
    }

    public void setNode(Node node) {
        this.modelElement = («sme.modelElement.name.toFirstUpper») node;
    }

    public Node getNode(){
        return this.modelElement;
    }


    public void update() {

    }

    public boolean delete() {
        long id = this.modelElement.getId();
        //Remove all outgoing edges
        //getOutgoing().forEach(de.ls5.cinco.transformation.api.CEdge::delete);
        //Remove all incomming edges
        //getIncoming().forEach(de.ls5.cinco.transformation.api.CEdge::delete);
        this.c«graphModel.name.toFirstUpper».getGraphModel().getmodelElements_ModelElement().remove(this.modelElement);
        this.c«graphModel.name.toFirstUpper».getPointController().deletePoint(this.modelElement.getposition());
        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
        this.c«graphModel.name.toFirstUpper».get«sme.modelElement.name.toFirstUpper»Controller().delete«sme.modelElement.name.toFirstUpper»(this.modelElement);
        
        PyroRemoveNodeCommand pyroRemoveNodeCommand = c«graphModel.name.toFirstUpper».getPyroRemoveNodeCommandController().createPyroRemoveNodeCommand("Remove«sme.modelElement.name.toFirstUpper»" + new Date().getTime());
		pyroRemoveNodeCommand.settime(new Date());
		pyroRemoveNodeCommand.setdywaId(id);
		pyroRemoveNodeCommand.settype("«sme.modelElement.name.toFirstUpper»");
		//pyroRemoveNodeCommand.setnode(this.modelElement);
		c«graphModel.name.toFirstUpper».getGraphModel().getpyroCommandStack_PyroCommand().add(pyroRemoveNodeCommand);
        
        
        return true;
    }

    public <T extends CGraphModel> T getCRootElement() {
        CModelElementContainer container = this.getContainer();
        if(container!=null){
            while(container != null && !(container instanceof CGraphModel))
                container = ((CModelElement) container).getContainer();
            if(container!=null)
                return (T) container;
        }

        return null;
    }
    
    public void setModelElement(ModelElement modelElement){
        this.modelElement = («sme.modelElement.name.toFirstUpper»)modelElement;
    }

    public ModelElement getModelElement(){
        return this.modelElement;
    }

}
	
	'''
	
	static def createEdges(String prefix,ArrayList<ConnectionConstraint> validConnections,StyledModelElement sme,String graphModelName)
	'''
	@Override
	public List<CEdge> get«prefix.toFirstUpper»() {
		List<CEdge> cEdges = new ArrayList<>();
        for(Edge edge:this.modelElement.get«prefix.toFirstLower»_Edge()){
        	«FOR ConnectionConstraint cc:validConnections»
        	if(edge instanceof «cc.connectingEdge.modelElement.name.toFirstUpper»){
			    C«cc.connectingEdge.modelElement.name.toFirstUpper» c«cc.connectingEdge.modelElement.name.toFirstUpper» = new C«cc.connectingEdge.modelElement.name.toFirstUpper»Impl();
			    c«cc.connectingEdge.modelElement.name.toFirstUpper».setModelElement(edge);
			    c«cc.connectingEdge.modelElement.name.toFirstUpper».setC«graphModelName.toFirstUpper»(this.c«graphModelName.toFirstUpper»);
				continue;
			}
            «ENDFOR»
        }
        return cEdges;
	}
	'''
	
	static def createEdge(ConnectionConstraint cc,String graphModelName)
	'''
	public C«cc.connectingEdge.modelElement.name.toFirstUpper» newC«cc.connectingEdge.modelElement.name.toFirstUpper»(C«cc.targetNode.modelElement.name.toFirstUpper» target) {
	    //CREATE EDGE COMMAND
		«cc.connectingEdge.modelElement.name.toFirstUpper» «cc.connectingEdge.modelElement.name.toFirstLower» = this.c«graphModelName.toFirstUpper».get«cc.connectingEdge.modelElement.name.toFirstUpper»Controller().create«cc.connectingEdge.modelElement.name.toFirstUpper»("«cc.connectingEdge.modelElement.name.toFirstLower»" + new Date().getTime());
		«cc.connectingEdge.modelElement.name.toFirstLower».setsourceElement(this.modelElement);
		«cc.connectingEdge.modelElement.name.toFirstLower».settargetElement((Node) target.getModelElement());
		«cc.connectingEdge.modelElement.name.toFirstLower».setcontainer(this.modelElement.getcontainer());
		this.c«graphModelName.toFirstUpper».getGraphModel().getmodelElements_ModelElement().add(«cc.connectingEdge.modelElement.name.toFirstLower»);
		
		this.modelElement.getoutgoing_Edge().add(«cc.connectingEdge.modelElement.name.toFirstLower»);
	    ((Node) target.getModelElement()).getincoming_Edge().add(«cc.connectingEdge.modelElement.name.toFirstLower»);
		
		C«cc.connectingEdge.modelElement.name.toFirstUpper» c«cc.connectingEdge.modelElement.name.toFirstUpper» = new C«cc.connectingEdge.modelElement.name.toFirstUpper»Impl();
		c«cc.connectingEdge.modelElement.name.toFirstUpper».setModelElement(«cc.connectingEdge.modelElement.name.toFirstLower»);
		c«cc.connectingEdge.modelElement.name.toFirstUpper».setC«graphModelName.toFirstUpper»(this.c«graphModelName.toFirstUpper»);
        PyroCreateEdgeCommand pyroCreateEdgeCommand = c«graphModelName.toFirstUpper».getPyroCreateEdgeCommandController().createPyroCreateEdgeCommand("Create«cc.connectingEdge.modelElement.name.toFirstUpper»" + new Date().getTime());
        pyroCreateEdgeCommand.settime(new Date());
        pyroCreateEdgeCommand.setdywaId(«cc.connectingEdge.modelElement.name.toFirstLower».getId());
        pyroCreateEdgeCommand.settype("«cc.connectingEdge.modelElement.name.toFirstUpper»");
        pyroCreateEdgeCommand.setsourceDywaId(this.modelElement.getId());
        pyroCreateEdgeCommand.settargetDywaId(target.getModelElement().getId());
        c«graphModelName.toFirstUpper».getGraphModel().getpyroCommandStack_PyroCommand().add(pyroCreateEdgeCommand);
		return c«cc.connectingEdge.modelElement.name.toFirstUpper»;
	}
	'''
	
	static def createCessor(String cessor,StyledNode sn)
	'''
	public List<C«sn.modelElement.name.toFirstUpper»> get«sn.modelElement.name.toFirstUpper»«cessor»cessor() {
	    return getPredecessors(C«sn.modelElement.name.toFirstUpper».class);
	}
	'''
	
	

	static def containsEdge(String name,String source, int counter, ArrayList<ConnectionConstraint> ccs){
	for(Integer i: counter+1..ccs.size){
		if(ccs.get(i).sourceNode.modelElement.name.equals(source) && name.equals(ccs.get(i).connectingEdge.modelElement.name)){
			return true;
		}
	}
	return false;
}

	
}