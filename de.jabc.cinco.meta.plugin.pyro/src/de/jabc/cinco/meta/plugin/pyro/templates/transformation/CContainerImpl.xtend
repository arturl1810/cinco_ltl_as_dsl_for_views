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

class CContainerImpl implements ElementTemplateable {

	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes,
		ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes,
		ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints,
		ArrayList<Type> enums) '''
package de.ls5.cinco.transformation.api.«graphModel.name.toFirstLower»;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;
import de.ls5.cinco.transformation.api.*;

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
    public void moveTo(final C«graphModel.name.toFirstUpper» container, long x, long y) {
    	this.moveTo(x,y);
        this.setContainer(container);
	}
	public C«sme.modelElement.name.toFirstUpper» clone(C«graphModel.name.toFirstUpper» target) {
		//COPY COMMAND
		return target.newC«sme.modelElement.name.toFirstUpper»(this.getX(),this.getY(),this.getWidth(),this.getHeight());
	}
	   
	«CNodeImpl.createEdges("Incoming", validConnections, sme,graphModel.name)»
    
    «CNodeImpl.createEdges("Outgoing", validConnections, sme,graphModel.name)»
    
    @Override
    public CModelElementContainer getContainer() {
    	if(modelElement.getcontainer() instanceof «graphModel.name.toFirstUpper»){
            return this.c«graphModel.name.toFirstUpper»;
        }
        «FOR EmbeddingConstraint ec : embeddingConstraints»
        «FOR GraphicalModelElement gm : ec.validNode»
        «IF gm.name.equals(sme.modelElement.name)»
        if(modelElement.getcontainer() instanceof «ec.container.name.toFirstUpper»){
            C«ec.container.name.toFirstUpper» c«ec.container.name.toFirstUpper» = new C«ec.container.name.toFirstUpper»Impl();
            c«ec.container.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this.c«graphModel.name.toFirstUpper»);
            c«ec.container.name.toFirstUpper».setModelElementContainer(modelElement.getcontainer());
        }
        «ENDIF»
        «ENDFOR»
        «ENDFOR»
    	return null;
    }
    
    @Override
    public List<CModelElement> getModelElements() {
        List<CModelElement> cModelElements = new ArrayList<CModelElement>();
        for(ModelElement me:this.modelElement.getmodelElements_ModelElement()) {
        	«FOR EmbeddingConstraint ec : embeddingConstraints»
    		«IF ec.container.name.equals(sme.modelElement.name)»
        	«FOR GraphicalModelElement gme : ec.validNode»
            if(me instanceof «gme.name.toFirstUpper»){
                C«gme.name.toFirstUpper» c«gme.name.toFirstUpper» = new C«gme.name.toFirstUpper»Impl();
                c«gme.name.toFirstUpper».setModelElement(me);
                c«gme.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this.c«graphModel.name.toFirstUpper»);
                cModelElements.add(c«gme.name.toFirstUpper»);
            }
            «ENDFOR»
            «ENDIF»
            «ENDFOR»
        }
        return cModelElements;
    }
    
    «FOR EmbeddingConstraint ec : embeddingConstraints»
    «IF ec.container.name.equals(sme.modelElement.name)»
    «createNewNode(ec, graphModel.name)»
    
    
    «ENDIF»
    «ENDFOR»

    @Override
    public void setContainer(CModelElementContainer container) {
        //COMMAND EMBEDD
        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
        this.modelElement.setcontainer(container.getModelElementContainer());
        container.getModelElementContainer().getmodelElements_ModelElement().add(this.modelElement);
    }

    
    «FOR ConnectionConstraint cc : validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «CNodeImpl.createEdge(cc,graphModel.name)»
    «ENDIF»
    «ENDFOR»
	«FOR EmbeddingConstraint ec : embeddingConstraints»
	«IF ec.container.name.equals(sme.modelElement.name)»
	«FOR GraphicalModelElement gme : ec.validNode»
	«createEmbedding(gme)»
	«ENDFOR»
	«ENDIF»
	«ENDFOR»
	
	
	public void addModelElement(CModelElement cModelElement) {
        //EMBEDD COMMAND
        this.modelElement.getmodelElements_ModelElement().add(cModelElement.getModelElement());
    }

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz) {
        List<T> list = new ArrayList<T>();
        for(CModelElement cModelElement : getModelElements()){
            if(clazz.isInstance(cModelElement)){
                list.add((T)cModelElement);
            }
        }
        return list;
    }

    public void setModelElements(List<CModelElement> cModelElements) {
        cModelElements.forEach(this::addModelElement);
    }

    public List<CNode> getAllCNodes() {
        return getCModelElements(CNode.class);
    }

    public List<CEdge> getAllCEdges() {
        return getCModelElements(CEdge.class);
    }

    public List<CContainer> getAllCContainers() {
        return getCModelElements(CContainer.class);
    }

    @Override
    public ModelElementContainer getModelElementContainer(){
        return this.modelElement;
    }
    
    public void setModelElementContainer(ModelElementContainer modelElementContainer){
        this.modelElement = («sme.modelElement.name.toFirstUpper»)modelElementContainer;
    }
    
    public void setModelElement(ModelElement modelElement){
        this.modelElement = («sme.modelElement.name.toFirstUpper»)modelElement;
    }

    public ModelElement getModelElement(){
        return this.modelElement;
    }
    
    «FOR Attribute attr : sme.modelElement.attributes»
    «CModelElementImpl.createAttribute(attr, sme,enums,graphModel)»
    «ENDFOR»
    «FOR ConnectionConstraint cc : validConnections»
    «IF cc.targetNode.modelElement.name.equals(sme.modelElement.name)»
    «CNodeImpl.createCessor("Prede", cc.sourceNode)»
    «ENDIF»
    «ENDFOR»
    «FOR ConnectionConstraint cc : validConnections»
    «IF cc.sourceNode.modelElement.name.equals(sme.modelElement.name)»
    «CNodeImpl.createCessor("Suc", cc.targetNode)»
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
        long relX = x - this.modelElement.getposition().getx();
		long relY = y - this.modelElement.getposition().gety();
		for(ModelElement modelElement:this.modelElement.getmodelElements_ModelElement()) {
			if(modelElement instanceof Node) {
				Node node = (Node) modelElement;
				node.getposition().setx(node.getposition().getx() + relX);
				node.getposition().sety(node.getposition().gety() + relY);
			}
			if(modelElement instanceof Edge) {
				Edge edge = (Edge) modelElement;
				for(Point point: edge.getbendingPoints_Point()) {
					point.setx(point.getx() + relX);
					point.sety(point.gety() + relY);
				}
			}
		}
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
        this.modelElement = («sme.modelElement.name.toFirstUpper»)node;
    }

    public Node getNode(){
        return this.modelElement;
    }


    public void update() {

    }

    public boolean delete() {
        long id = this.modelElement.getId();
        
        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
        //Remove all contained elements
        //getModelElements().forEach(de.ls5.cinco.transformation.api.CModelElement::delete);
        //Remove all outgoing edges
        //getOutgoing().forEach(de.ls5.cinco.transformation.api.CEdge::delete);
        //Remove all incomming edges
        //getIncoming().forEach(de.ls5.cinco.transformation.api.CEdge::delete);
        
        this.c«graphModel.name.toFirstUpper».getGraphModel().getmodelElements_ModelElement().remove(this.modelElement);
        this.c«graphModel.name.toFirstUpper».getPointController().deletePoint(this.modelElement.getposition());
        this.c«graphModel.name.toFirstUpper».get«sme.modelElement.name.toFirstUpper»Controller().delete«sme.modelElement.name.toFirstUpper»(this.modelElement);
        
        PyroRemoveNodeCommand pyroRemoveNodeCommand = c«graphModel.name.toFirstUpper».getPyroRemoveNodeCommandController().createPyroRemoveNodeCommand("Remove«sme.modelElement.name.toFirstUpper»" + new Date().getTime());
		pyroRemoveNodeCommand.settime(new Date());
		pyroRemoveNodeCommand.setdywaId(id);
		pyroRemoveNodeCommand.settype("«sme.modelElement.name.toFirstUpper»");
		pyroRemoveNodeCommand.setnode(this.modelElement);
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
   
}
	
	'''


	static def createEmbedding(GraphicalModelElement gme) '''
		public void addC«gme.name.toFirstUpper»(C«gme.name.toFirstUpper» node){
			addModelElement(node);
		}
	'''


	static def createNewNode(EmbeddingConstraint ec, String graphModelName) '''
		«FOR GraphicalModelElement gme : ec.validNode»
			public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y) {
			    C«gme.name.toFirstUpper» c«gme.name.toFirstUpper» = this.c«graphModelName.toFirstUpper».newC«gme.name.toFirstUpper»(x,y);
				c«gme.name.toFirstUpper».setContainer(this);
				this.c«graphModelName.toFirstUpper».getGraphModel().getmodelElements_ModelElement().add(c«gme.name.toFirstUpper».getModelElement());
				return c«gme.name.toFirstUpper»;
			}
			
			public C«gme.name.toFirstUpper» newC«gme.name.toFirstUpper»(long x,long y,long width,long height) {
			    C«gme.name.toFirstUpper» c«gme.name.toFirstUpper» = this.c«graphModelName.toFirstUpper».newC«gme.name.toFirstUpper»(x,y);
				c«gme.name.toFirstUpper».setContainer(this);
				c«gme.name.toFirstUpper».setWidth(width);
				c«gme.name.toFirstUpper».setHeight(height);
				this.c«graphModelName.toFirstUpper».getGraphModel().getmodelElements_ModelElement().add(c«gme.name.toFirstUpper».getModelElement());
				return c«gme.name.toFirstUpper»;
			}
			
			public C«gme.name.toFirstUpper» getC«gme.name.toFirstUpper»(«gme.name.toFirstUpper» «gme.name.toFirstLower») {
				for(CModelElement cModelElement:getModelElements()){
				    if(cModelElement instanceof C«gme.name.toFirstUpper» && cModelElement.getModelElement().getId() == «gme.name.toFirstLower».getId()){
				        return (C«gme.name.toFirstUpper») cModelElement;
					}
				}
				return null;
			}
			
			public List<C«gme.name.toFirstUpper»> getC«gme.name.toFirstUpper»s() {
				return this.getCModelElements(C«gme.name.toFirstUpper».class);
			}
			
		«ENDFOR»
	'''

}
