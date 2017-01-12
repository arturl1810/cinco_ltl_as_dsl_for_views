package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import java.util.List
import mgl.Attribute
import mgl.GraphicalModelElement
import mgl.NodeContainer

class CContainerImpl implements ElementTemplateable {

	override create(StyledModelElement sme,
		TemplateContainer tc) '''
			package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
			import de.ls5.dywa.generated.entity.*;
			import de.ls5.dywa.generated.controller.*;
			import de.ls5.cinco.pyro.transformation.api.*;
			«FOR EmbeddingConstraint ec : tc.embeddingConstraints.filter[ec|ec.container.name.equals(sme.modelElement.name)]»
			«createCustomeHookImports(ec,tc.graphModel.name)»
			«ENDFOR»
		
			import java.util.ArrayList;
			import java.util.Date;
			import java.util.List;
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
			    public void moveTo(final C«tc.graphModel.name.toFirstUpper» container, long x, long y) {
			    	this.moveTo(x,y);
			    	   this.setContainer(container);
				}
				public C«sme.modelElement.name.toFirstUpper» clone(C«tc.graphModel.name.toFirstUpper» target) {
					//COPY COMMAND
					return target.newC«sme.modelElement.name.toFirstUpper»(this.getX(),this.getY(),this.getWidth(),this.getHeight());
				}
				 
				«CNodeImpl.createEdges("Incoming", tc.validConnections, sme,tc.graphModel.name)»
				   
				   «CNodeImpl.createEdges("Outgoing", tc.validConnections, sme,tc.graphModel.name)»
				 
				   @Override
				   public CModelElementContainer getContainer() {
				   	if(modelElement.getcontainer() instanceof «tc.graphModel.name.toFirstUpper»){
				   	       return this.c«tc.graphModel.name.toFirstUpper»;
				   	   }
				   	   «FOR StyledNode sn : tc.nodes.filter[sn|sn.modelElement instanceof NodeContainer]»
				 	«IF ModelParser.isContainable(sme.modelElement,sn.modelElement as NodeContainer)»
				 		if(modelElement.getcontainer() instanceof «sn.modelElement.name.toFirstUpper»){
				 		    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
				 		    c«sn.modelElement.name.toFirstUpper».setC«tc.graphModel.name.toFirstUpper»(this.c«tc.graphModel.name.toFirstUpper»);
				 		    c«sn.modelElement.name.toFirstUpper».setModelElementContainer(modelElement.getcontainer());
				 		    return c«sn.modelElement.name.toFirstUpper»;
				 		}
				 	«ENDIF»
				 «ENDFOR»
				   	return null;
				   }
				   
				   @Override
				   public List<CModelElement> getModelElements() {
				       List<CModelElement> cModelElements = new ArrayList<CModelElement>();
				       for(ModelElement me:this.modelElement.getmodelElements_ModelElement()) {
				       	«FOR EmbeddingConstraint ec : tc.embeddingConstraints.filter[ec|ec.container.name.equals(sme.modelElement.name)]»
				       		«FOR GraphicalModelElement gme : ec.validNode»
				       			if(me instanceof «gme.name.toFirstUpper»){
				       			    C«gme.name.toFirstUpper» c«gme.name.toFirstUpper» = new C«gme.name.toFirstUpper»Impl();
				       			    c«gme.name.toFirstUpper».setModelElement(me);
				       			    c«gme.name.toFirstUpper».setC«tc.graphModel.name.toFirstUpper»(this.c«tc.graphModel.name.toFirstUpper»);
				       			    cModelElements.add(c«gme.name.toFirstUpper»);
				       			}
				       		«ENDFOR»
				       	«ENDFOR»
				       }
				       return cModelElements;
				   }
				 «createNewNode(sme.modelElement as NodeContainer, tc.graphModel.name,tc.nodes)»
		
		   @Override
		   public void setContainer(CModelElementContainer container) {
		    //COMMAND EMBEDD
		    this.modelElement.getcontainer().getmodelElements_ModelElement().remove(this.modelElement);
		    this.modelElement.setcontainer(container.getModelElementContainer());
		    container.getModelElementContainer().getmodelElements_ModelElement().add(this.modelElement);
		   }
		
		   
		   «FOR ConnectionConstraint cc : tc.validConnections.filter[cc|cc.sourceNode.modelElement.name.equals(sme.modelElement.name)]»
			«CNodeImpl.createEdge(cc,tc.graphModel.name)»
		   «ENDFOR»
		«FOR StyledNode sn : tc.nodes.filter[sn|ModelParser.isContainable(sn.modelElement,sme.modelElement as NodeContainer)]»
			«createEmbedding(sn.modelElement)»
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
		   	«CModelElementImpl.createAttribute(attr, sme,tc.enums,tc.graphModel)»
		   «ENDFOR»
		   «FOR ConnectionConstraint cc : tc.validConnections»
		   	«IF cc.targetNode.modelElement.name.equals(sme.modelElement.name)»
		   		«CNodeImpl.createCessor("Prede", cc.sourceNode)»
		   	«ENDIF»
		   «ENDFOR»
		   «FOR ConnectionConstraint cc : tc.validConnections»
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
		    
		    this.c«tc.graphModel.name.toFirstUpper».getGraphModel().getmodelElements_ModelElement().remove(this.modelElement);
		    this.c«tc.graphModel.name.toFirstUpper».getPointController().deletePoint(this.modelElement.getposition());
		    this.c«tc.graphModel.name.toFirstUpper».get«sme.modelElement.name.toFirstUpper»Controller().delete«sme.modelElement.name.toFirstUpper»(this.modelElement);
		    
		    PyroRemoveNodeCommand pyroRemoveNodeCommand = c«tc.graphModel.name.toFirstUpper».getPyroRemoveNodeCommandController().createPyroRemoveNodeCommand("Remove«sme.modelElement.name.toFirstUpper»" + new Date().getTime());
			pyroRemoveNodeCommand.settime(new Date());
			pyroRemoveNodeCommand.setdywaId(id);
			pyroRemoveNodeCommand.settype("«sme.modelElement.name.toFirstUpper»");
			//pyroRemoveNodeCommand.setnode(this.modelElement);
			c«tc.graphModel.name.toFirstUpper».getGraphModel().getpyroCommandStack_PyroCommand().add(pyroRemoveNodeCommand);
			      
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

	static def createCustomeHookImports(EmbeddingConstraint ec, String graphModelName) '''
		«FOR GraphicalModelElement gme : ec.validNode»
			«IF ModelParser.isCustomeHook(gme)»
				import de.ls5.cinco.pyro.custom.hook.«graphModelName.toFirstLower».«ModelParser.getCustomeHookName(gme).toFirstUpper»CustomHook;
			«ENDIF»
		«ENDFOR»
	'''

	static def createNewNode(NodeContainer nc, String graphModelName, List<StyledNode> nodes) '''
		«FOR StyledNode sn : nodes»
			«IF ModelParser.isContainable(sn.modelElement,nc)»
				public C«sn.modelElement.name.toFirstUpper» newC«sn.modelElement.name.toFirstUpper»(long x,long y) {
					return this.newC«sn.modelElement.name.toFirstUpper»(x,y,«ModelParser.getStyledNode(nodes,sn.modelElement.name).width»,«ModelParser.getStyledNode(nodes,sn.modelElement.name).height»);
				}
				
				public C«sn.modelElement.name.toFirstUpper» newC«sn.modelElement.name.toFirstUpper»(long x,long y,long width,long height) {
					«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower» = this.c«graphModelName».get«sn.modelElement.name.toFirstUpper»Controller().create«sn.modelElement.name.toFirstUpper»("«sn.modelElement.name.toFirstLower»"+new Date().getTime());
					«sn.modelElement.name.toFirstLower».setheight(height);
					«sn.modelElement.name.toFirstLower».setwidth(width);
					«sn.modelElement.name.toFirstLower».setangle(«ModelParser.getStyledNode(nodes,sn.modelElement.name).angle».0);
					«sn.modelElement.name.toFirstLower».setcontainer(this.modelElement);
					Point point = this.c«graphModelName».getPointController().createPoint("point"+new Date().getTime());
					point.setx(x);
					point.sety(y);
					«sn.modelElement.name.toFirstLower».setposition(point);
					this.modelElement.getmodelElements_ModelElement().add(«sn.modelElement.name.toFirstLower»);
					C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = new C«sn.modelElement.name.toFirstUpper»Impl();
					c«sn.modelElement.name.toFirstUpper».setModelElement(«sn.modelElement.name.toFirstLower»);
					c«sn.modelElement.name.toFirstUpper».setC«graphModelName.toFirstUpper»(this.c«graphModelName.toFirstUpper»);
					PyroCreateNodeCommand pyroCreateNodeCommand = this.c«graphModelName».getPyroCreateNodeCommandController().createPyroCreateNodeCommand("Create«sn.modelElement.name.toFirstUpper»" + new Date().getTime());
					pyroCreateNodeCommand.settype("«sn.modelElement.name.toFirstUpper»");
					pyroCreateNodeCommand.setx((double) x);
					pyroCreateNodeCommand.sety((double) y);
					pyroCreateNodeCommand.setdywaId(«sn.modelElement.name.toFirstLower».getId());
					pyroCreateNodeCommand.settime(new Date());
					this.c«graphModelName».getGraphModel().getpyroCommandStack_PyroCommand().add(pyroCreateNodeCommand);
					«IF ModelParser.isCustomeHook(sn.modelElement)»
						//Post Create Hook
						«ModelParser.getCustomeHookName(sn.modelElement).toFirstUpper»CustomHook «ModelParser.getCustomeHookName(sn.modelElement).toFirstLower»CustomHook = new «ModelParser.getCustomeHookName(sn.modelElement).toFirstUpper»CustomHook();
						if(«ModelParser.getCustomeHookName(sn.modelElement).toFirstLower»CustomHook.canExecute(c«sn.modelElement.name.toFirstUpper»)){
							«ModelParser.getCustomeHookName(sn.modelElement).toFirstLower»CustomHook.execute(c«sn.modelElement.name.toFirstUpper»);
						}
					«ENDIF»
					return c«sn.modelElement.name.toFirstUpper»;
				}
				
				public C«sn.modelElement.name.toFirstUpper» getC«sn.modelElement.name.toFirstUpper»(«sn.modelElement.name.toFirstUpper» «sn.modelElement.name.toFirstLower») {
					for(CModelElement cModelElement:getModelElements()){
					    if(cModelElement instanceof C«sn.modelElement.name.toFirstUpper» && cModelElement.getModelElement().getId() == «sn.modelElement.name.toFirstLower».getId()){
					        return (C«sn.modelElement.name.toFirstUpper») cModelElement;
						}
					}
					return null;
				}
				
				public List<C«sn.modelElement.name.toFirstUpper»> getC«sn.modelElement.name.toFirstUpper»s() {
					return this.getCModelElements(C«sn.modelElement.name.toFirstUpper».class);
				}
			«ENDIF»
		«ENDFOR»
	'''
}
