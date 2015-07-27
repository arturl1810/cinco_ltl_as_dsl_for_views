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
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class CGraphModelImpl implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.*;
import de.ls5.dywa.generated.controller.*;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.inject.Named;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by Pyro CINCO Meta Plugin.
 */
@Named("c«graphModel.name.toFirstUpper»")
@RequestScoped
public class C«graphModel.name.toFirstUpper»Impl implements C«graphModel.name.toFirstUpper»{
	
	protected «graphModel.name.toFirstUpper» modelElementContainer;
	
	@Inject
    private «graphModel.name.toFirstUpper»Controller «graphModel.name.toFirstLower»Controller;

    @Inject
    private PointController pointController;
	
	«FOR StyledNode sn:nodes»
	@Inject
	private «sn.modelElement.name.toFirstUpper»Controller «sn.modelElement.name.toFirstLower»Controller;
	
	@Inject
	private Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController;
	
    «ENDFOR»
    
    «FOR StyledEdge se:edges»
    @Inject
    private «se.modelElement.name.toFirstUpper»Controller «se.modelElement.name.toFirstLower»Controller;
    
    @Inject
	private Pyro«se.modelElement.name.toFirstUpper»AttributeCommandController pyro«se.modelElement.name.toFirstUpper»AttributeCommandController;
	
    «ENDFOR»
	
	«FOR StyledNode sn:nodes»
	public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller() {
		return this.«sn.modelElement.name.toFirstLower»Controller;
	}
	
	public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController() {
		return this.pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController;
	}
    «ENDFOR»
    
    «FOR StyledEdge sn:edges»
    public «sn.modelElement.name.toFirstUpper»Controller get«sn.modelElement.name.toFirstUpper»Controller() {
    	return this.«sn.modelElement.name.toFirstLower»Controller;
    }
    
    public Pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController getPyro«sn.modelElement.name.toFirstUpper»AttributeCommandController() {
		return this.pyro«sn.modelElement.name.toFirstUpper»AttributeCommandController;
	}
    
    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower») {
    	return getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstLower».getId());
    }
    
    public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id) {
        «sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower» = this.«sn.modelElement.name.toFirstLower»Controller.read«sn.modelElement.name.toFirstUpper»(id);
    	if(«sn.modelElement.name.toFirstLower» == null) {
    	    return null;
    	}
    	C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
    	c«sn.modelElement.name.toFirstUpper».setModelElement(«sn.modelElement.name.toFirstLower»);
    	c«sn.modelElement.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this);
    	return c«sn.modelElement.name.toFirstUpper»;
    
    }
    «ENDFOR»
	
	public void setModelElementContainer(«graphModel.name.toFirstUpper» modelElementContainer) {
        this.modelElementContainer = modelElementContainer;
    }
	
    public String getCName(){
        return "«graphModel.name.toFirstUpper»";
    }
    
    public PointController getPointController() {
        return pointController;
    }

    public void setPointController(PointController pointController) {
        this.pointController = pointController;
    }
    
    public «graphModel.name.toFirstUpper»Controller get«graphModel.name.toFirstUpper»Controller() {
        return «graphModel.name.toFirstLower»Controller;
    }

    public void set«graphModel.name.toFirstUpper»Controller(«graphModel.name.toFirstUpper»Controller «graphModel.name.toFirstLower»Controller) {
        this.«graphModel.name.toFirstLower»Controller = «graphModel.name.toFirstLower»Controller;
    }
    
    private List<ModelElement> getRecursiveModelElemements(List<ModelElement> modelElements) {
        List<ModelElement> output = new ArrayList<>(modelElements);
        modelElements.stream().filter(modelElement -> modelElement instanceof Container).forEach(modelElement -> {
            Container container = (Container) modelElement;
            output.addAll(getRecursiveModelElemements(container.getmodelElements_ModelElement()));
        });
        return output;
    }
    
    @Override
    public List<CModelElement> getModelElements() {
        List<CModelElement> cModelElements = new ArrayList<CModelElement>();
        for(ModelElement me:getRecursiveModelElemements(this.modelElementContainer.getmodelElements_ModelElement())) {
        	«FOR StyledNode sn:nodes»
			if(me instanceof «sn.modelElement.name.toFirstUpper»){
			    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
			    c«sn.modelElement.name.toFirstUpper».setModelElement(me);
			    c«sn.modelElement.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this);
			    cModelElements.add(c«sn.modelElement.name.toFirstUpper»);
			}
            «ENDFOR»
            «FOR StyledEdge sn:edges»
			if(me instanceof «sn.modelElement.name.toFirstUpper»){
			    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
			    c«sn.modelElement.name.toFirstUpper».setModelElement(me);
			    c«sn.modelElement.name.toFirstUpper».setC«graphModel.name.toFirstUpper»(this);
			    cModelElements.add(c«sn.modelElement.name.toFirstUpper»);
			}
            «ENDFOR»
        }
        return cModelElements;
    }
    
    «FOR StyledNode sn:nodes»
    «createNewNode(sn,graphModel.name,validConnections)»
    «ENDFOR»

    «FOR Attribute attr: graphModel.attributes»
    «createAttribute(attr,graphModel)»
    «ENDFOR»
    
    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz) {
        List<T> list = getModelElements().stream().filter(cModelElement -> clazz.isInstance(cModelElement)).map(cModelElement -> (T) cModelElement).collect(Collectors.toList());
        return list;
    }

    public void setModelElements(List<CModelElement> cModelElements) {
        //COMMAND EMBED
        for(CModelElement cModelElement:cModelElements){
            this.modelElementContainer.getmodelElements_ModelElement().add(cModelElement.getModelElement());
        }
    }

    public void addModelElement(CModelElement cModelElement) {
        //EMBEDD COMMAND
        this.getModelElements().add(cModelElement);
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

    public GraphModel getGraphModel() {
        return this.modelElementContainer;
    }

    public void setGraphModel(GraphModel graphModel) {
        this.modelElementContainer = («graphModel.name.toFirstUpper») graphModel;
    }

    public ModelElementContainer getModelElementContainer(){
        return this.modelElementContainer;
    }

    public void setModelElementContainer(ModelElementContainer modelElementContainer){
        this.modelElementContainer = («graphModel.name.toFirstUpper») modelElementContainer;
    }
}
	
	'''
	
	def createEdges(String prefix,ArrayList<ConnectionConstraint> validConnections,StyledModelElement sme)
	'''
	@Override
    public List<CEdge> get«prefix.toFirstUpper»() {
        List<CEdge> edges = new ArrayList<CEdge>();
        for(Edge edge:this.modelElement.get«prefix.toFirstLower»_Edge()){
        	«FOR ConnectionConstraint cc:validConnections»
        	«IF cc.targetNode.modelElement.name.equals(sme.modelElement.name)»
        	if(edge instanceof «cc.connectingEdge.modelElement.name.toFirstUpper»){
			    C«cc.connectingEdge.modelElement.name.toFirstUpper» c«cc.connectingEdge.modelElement.name.toFirstUpper» = new C«cc.connectingEdge.modelElement.name.toFirstUpper»Impl();
			    c«cc.connectingEdge.modelElement.name.toFirstUpper».setModelElement(edge);
			    edges.add(c«cc.connectingEdge.modelElement.name.toFirstUpper»);
			}
            «ENDIF»
            «ENDFOR»
        }
        return edges;
    }
    
	'''
	
	def createEmbedding(GraphicalModelElement gme)
	'''
	public void addC«gme.name.toFirstUpper»(C«gme.name.toFirstUpper» node){
		//EMBEDD COMMAND
	}
	'''
	
	def createNewEdge(ConnectionConstraint cc)
	'''
	public C«cc.connectingEdge.modelElement.name.toFirstUpper» newC«cc.connectingEdge.modelElement.name.toFirstUpper»(C«cc.targetNode.modelElement.name.toFirstUpper» target) {
	    //CREATE EDGE COMMAND
	    return null;
	}
	'''
	
	def createNewNode(StyledNode sn,String graphModelName,ArrayList<ConnectionConstraint> validConnections)
	'''
	public C«sn.modelElement.name.toFirstUpper» newC«sn.modelElement.name.toFirstUpper»(long x,long y) {
	    return newC«sn.modelElement.name.toFirstUpper»(x,y,«sn.width»,«sn.height»);
	}
	
	public C«sn.modelElement.name.toFirstUpper» newC«sn.modelElement.name.toFirstUpper»(long x,long y,long width,long height) {
	    «sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower» = «sn.modelElement.name.toFirstLower»Controller.create«sn.modelElement.name.toFirstUpper»("«sn.modelElement.name.toFirstLower»"+new Date().getTime());
		«sn.modelElement.name.toFirstLower».setheight(height);
		«sn.modelElement.name.toFirstLower».setwidth(width);
		«sn.modelElement.name.toFirstLower».setangle(«sn.angle».0);
		«sn.modelElement.name.toFirstLower».setcontainer(this.modelElementContainer);
		Point point = this.pointController.createPoint("point"+new Date().getTime());
		point.setx(x);
		point.sety(y);
		«sn.modelElement.name.toFirstLower».setposition(point);
		this.modelElementContainer.getmodelElements_ModelElement().add(«sn.modelElement.name.toFirstLower»);
		C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
		c«sn.modelElement.name.toFirstUpper».setModelElement(«sn.modelElement.name.toFirstLower»);
		c«sn.modelElement.name.toFirstUpper».setC«graphModelName.toFirstUpper»(this);
		return c«sn.modelElement.name.toFirstUpper»;
	}
	
	public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower») {
		return getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstLower».getId());
	}
	
	public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(long id) {
	    «sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower» = this.«sn.modelElement.name.toFirstLower»Controller.read«sn.modelElement.name.toFirstUpper»(id);
		if(«sn.modelElement.name.toFirstLower» == null) {
		    return null;
		}
		C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
		c«sn.modelElement.name.toFirstUpper».setModelElement(«sn.modelElement.name.toFirstLower»);
		c«sn.modelElement.name.toFirstUpper».setC«graphModelName.toFirstUpper»(this);
		return c«sn.modelElement.name.toFirstUpper»;

	}
	
	public List<C«sn.modelElement.name.toFirstUpper»> getC«sn.modelElement.name.toFirstUpper»s() {
		return this.getCModelElements(C«sn.modelElement.name.toFirstUpper».class);
	}
	'''
	
	
	def createCessor(String cessor,StyledNode sn)
	'''
	public List<C«sn.modelElement.name.toFirstUpper»> get«sn.modelElement.name.toFirstUpper»«cessor»cessor() {
	    return getPredecessors(C«sn.modelElement.name.toFirstUpper».class);
	}
	'''
	
	def createAttribute(mgl.Attribute attribute,GraphModel g)
	'''
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,g)»
	«ELSE»
	«createListAttribute(attribute,g)»
	«ENDIF»
	
	'''
	
	def createPrimativeAttribute(mgl.Attribute attribute,GraphModel g)
	'''
	public «getAttributeType(attribute.type)» get«attribute.name.toFirstUpper»(){
		return this.modelElementContainer.get«attribute.name.toFirstLower»();
	}
	
	public void set«attribute.name.toFirstUpper»(«getAttributeType(attribute.type)» «attribute.name.toFirstLower») {
	    this.modelElementContainer.set«attribute.name.toFirstLower»(«attribute.name.toFirstLower»);
	}
	'''
	
	def createListAttribute(mgl.Attribute attribute,GraphModel g)
	'''
	public List<String> get«attribute.name.toFirstUpper»(){
		return this.modelElementContainer.get«attribute.name.toFirstLower»();
	}
	
	public void set«attribute.name.toFirstUpper»(List<String> «attribute.name.toFirstLower») {
	    this.modelElementContainer.set«attribute.name.toFirstLower»(«attribute.name.toFirstLower»);
	}
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