package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import mgl.Attribute
import mgl.GraphicalModelElement

class CEdgeImpl implements ElementTemplateable{
	
	override create(StyledModelElement sme, TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
		import de.ls5.dywa.generated.entity.*;
		import de.ls5.dywa.generated.controller.*;
		import de.ls5.cinco.pyro.transformation.api.*;
		
		import java.util.ArrayList;
		import java.util.List;
		import java.util.Date;
		import java.util.stream.Collectors;
		
		/**
		 * Created by Pyro CINCO Meta Plugin.
		 */
		public class C«sme.modelElement.name.toFirstUpper»Impl implements C«sme.modelElement.name.toFirstUpper»{
			
			protected «sme.modelElement.name.toFirstUpper» modelElement;
			
			protected C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper»;
		    
		    public C«tc.graphModel.name.toFirstUpper» getC«tc.graphModel.name.toFirstUpper»() {
		        return c«tc.graphModel.name.toFirstUpper»;
		    }
		
		    public void setC«tc.graphModel.name.toFirstUpper»(C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper») {
		        this.c«tc.graphModel.name.toFirstUpper» = c«tc.graphModel.name.toFirstUpper»;
		    }
			
		    public String getCName(){
		        return "«sme.modelElement.name.toFirstUpper»";
		    }
		    «FOR Attribute attr: sme.modelElement.attributes»
		    «CModelElementImpl.createAttribute(attr,sme,tc.enums,tc.graphModel)»
		    «ENDFOR»
		    
		    public CNode getSourceElement() {
		    	«FOR ConnectionConstraint cc: tc.validConnections.filter[cc|cc.connectingEdge.modelElement.name.equals(sme.modelElement.name)]»
			    	if(this.modelElement.getsourceElement() instanceof «cc.sourceNode.modelElement.name.toFirstUpper») {
			            C«cc.sourceNode.modelElement.name.toFirstUpper» c«cc.sourceNode.modelElement.name.toFirstUpper» = new C«cc.sourceNode.modelElement.name.toFirstUpper»Impl();
			            c«cc.sourceNode.modelElement.name.toFirstUpper».setC«tc.graphModel.name.toFirstUpper»(this.c«tc.graphModel.name.toFirstUpper»);
			            c«cc.sourceNode.modelElement.name.toFirstUpper».setModelElement(this.modelElement.getsourceElement());
			            return c«cc.sourceNode.modelElement.name.toFirstUpper»;
			        }
		        «ENDFOR»
		        return null;
		    }
		
		
		    public CNode getTargetElement() {
		    	«FOR ConnectionConstraint cc: tc.validConnections.filter[cc|cc.connectingEdge.modelElement.name.equals(sme.modelElement.name)]»
			    	if(this.modelElement.gettargetElement() instanceof «cc.targetNode.modelElement.name.toFirstUpper») {
			            C«cc.targetNode.modelElement.name.toFirstUpper» c«cc.targetNode.modelElement.name.toFirstUpper» = new C«cc.targetNode.modelElement.name.toFirstUpper»Impl();
			            c«cc.targetNode.modelElement.name.toFirstUpper».setC«tc.graphModel.name.toFirstUpper»(this.c«tc.graphModel.name.toFirstUpper»);
			            c«cc.targetNode.modelElement.name.toFirstUpper».setModelElement(this.modelElement.gettargetElement());
			            return c«cc.targetNode.modelElement.name.toFirstUpper»;
			        }
		        «ENDFOR»
		        return null;
		    }
		    
		    public CModelElementContainer getContainer() {
		    	if(modelElement.getcontainer() instanceof «tc.graphModel.name.toFirstUpper»){
		            return this.c«tc.graphModel.name.toFirstUpper»;
		        }
		        «FOR EmbeddingConstraint ec:tc.embeddingConstraints»
			        «FOR GraphicalModelElement gm : ec.validNode.filter[gm|gm.name.equals(sme.modelElement.name)]»
					        if(modelElement.getcontainer() instanceof «ec.container.name.toFirstUpper»){
					            C«ec.container.name.toFirstUpper» c«ec.container.name.toFirstUpper» = new C«ec.container.name.toFirstUpper»Impl();
					            c«ec.container.name.toFirstUpper».setC«tc.graphModel.name.toFirstUpper»(this.c«tc.graphModel.name.toFirstUpper»);
					            c«ec.container.name.toFirstUpper».setModelElementContainer(modelElement.getcontainer());
					        }
			        «ENDFOR»
		        «ENDFOR»
		    	return null;
		    }
		    
		    public void setContainer(CModelElementContainer container) {
		        //COMMAND EMBEDD
		        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
		        this.modelElement.setcontainer(container.getModelElementContainer());
		        container.getModelElementContainer().getmodelElements_ModelElement().add(this.modelElement);
		    }
		    public void reconnectSource(CNode cNode){
		        setSourceElement(cNode);
		    }
		
		    public void reconnectTarget(CNode cNode){
		        setTargetElement(cNode);
		    }
		
		    public void setTargetElement(CNode value){
		        //COMMAND EDGE EDIT TARGET
		        modelElement.settargetElement(value.getNode());
		    }
		
		    public void addBendingPoint(long x,long y){
		        //EDIT VERTEX COMMAND
		        Point point = this.c«tc.graphModel.name.toFirstUpper».getPointController().createPoint("point"+new Date().getTime());
		        point.setx(x);
		        point.sety(y);
		        this.modelElement.getbendingPoints_Point().add(point);
		    }
		
		    public void addBendingPoint(CBendingpoint bendingpoint){
		        List<CBendingpoint> cBendingpoints = new ArrayList<CBendingpoint>(getBendingpoints());
		        cBendingpoints.add(bendingpoint);
		        setBendingPoints(cBendingpoints);
		    }
		
		    public List<CBendingpoint> getBendingpoints(){
				List<CBendingpoint> cBendingpoints = modelElement.getbendingPoints_Point().stream().map(CBendingpointImpl::new).collect(Collectors.toList());
		        return cBendingpoints;
		    }
		    
		    public void removeAllBendingPoints() {
		    	this.modelElement.getbendingPoints_Point().clear();
		        for(Point point : modelElement.getbendingPoints_Point()) {
		            this.c«tc.graphModel.name.toFirstUpper».getPointController().deletePoint(point);
		        }
		    }
		
		    public void setBendingPoints(List<CBendingpoint> bendingPoints){
		        modelElement.getbendingPoints_Point().clear();
		        
		        removeAllBendingPoints();
		        
		        for(Point point : modelElement.getbendingPoints_Point()) {
		            addBendingPoint(point.getx(),point.gety());
		        }
		    }
		
		    public void setEdge(«sme.modelElement.name.toFirstUpper» edge) {
		        this.modelElement = edge;
		    }
		
		    public «sme.modelElement.name.toFirstUpper» getEdge() {
		        return this.modelElement;
		    }
		    
		
		    @Override
		    public void update() {
		
		    }
		
		    @Override
		    public boolean delete() {
		        long id = this.modelElement.getId();
		        
		        this.modelElement.getbendingPoints_Point().forEach(this.c«tc.graphModel.name.toFirstUpper».getPointController()::deletePoint);
		        this.modelElement.getsourceElement().getoutgoing_Edge().remove(this.modelElement);
		        this.modelElement.gettargetElement().getincoming_Edge().remove(this.modelElement);
		        this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
		        this.c«tc.graphModel.name.toFirstUpper».getGraphModel().getmodelElements_ModelElement().remove(this.modelElement);
		        this.c«tc.graphModel.name.toFirstUpper».get«sme.modelElement.name.toFirstUpper»Controller().delete«sme.modelElement.name.toFirstUpper»(this.modelElement);
		        
		        PyroRemoveEdgeCommand pyroRemoveEdgeCommand = c«tc.graphModel.name.toFirstUpper».getPyroRemoveEdgeCommandController().createPyroRemoveEdgeCommand("Remove«sme.modelElement.name.toFirstUpper»" + new Date().getTime());
				pyroRemoveEdgeCommand.settime(new Date());
				pyroRemoveEdgeCommand.setdywaId(id);
				pyroRemoveEdgeCommand.settype("«sme.modelElement.name.toFirstUpper»");
				//pyroRemoveEdgeCommand.setedge(this.modelElement);
				c«tc.graphModel.name.toFirstUpper».getGraphModel().getpyroCommandStack_PyroCommand().add(pyroRemoveEdgeCommand);
		        
		        return true;
		    }
		
		    @Override
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
		        this.modelElement = («sme.modelElement.name.toFirstUpper») modelElement;
		    }
		
		    public ModelElement getModelElement(){
		        return this.modelElement;
		    }
		    
		    @Override
		    public void setEdge(Edge edge) {
		        this.modelElement = («sme.modelElement.name.toFirstUpper») edge;
		    }
		    
		    @Override
		    public void setSourceElement(CNode value) {
		    	//CHANGE SOURCE COMMAND
		    	this.modelElement.setsourceElement(value.getNode());
		    }
		
		}
	'''
}