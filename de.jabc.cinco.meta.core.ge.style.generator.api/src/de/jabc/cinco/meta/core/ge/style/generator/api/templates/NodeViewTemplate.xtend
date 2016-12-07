package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractAddFeature
import graphicalgraphmodel.CContainer
import graphicalgraphmodel.CGraphModel
import graphicalgraphmodel.CModelElementContainer
import java.util.List
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.Type
import org.eclipse.graphiti.features.IAddFeature
import org.eclipse.graphiti.features.IMoveShapeFeature
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.MoveShapeContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape

class NodeViewTemplate extends ModelElementTemplate implements MovableElementTemplate{
	
	new(ModelElement me) {
		super(me)
	}
	
	def outgoingEdgesGetter(Node n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.getCName»> getOutgoing«e.getCName.toFirstUpper» () {
		return this.getViewable().getOutgoing(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def outgoingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.getCName»> getOutgoing«e.getCName.toFirstUpper» () {
		return this.getViewable().getOutgoing(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(Node n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.getCName»> getIncoming«e.getCName.toFirstUpper» () {
		return this.getViewable().getIncoming(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.getCName»> getIncoming«e.getCName.toFirstUpper» () {
		return this.getViewable().getIncoming(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def viewableGetter(Node n)'''
	public «n.fqcn» getViewable(){
		return this.viewable;
	}
	'''
	
	def viewableSetter(Node n)'''
	public void setViewable(«n.fqcn» cNode) {
		this.viewable = cNode;
	}
	'''
	
	def newEdgeMethod(Edge out, Node source)
	'''«FOR target : out.possibleTargets»
		«out.newEdgeMethod(source,target)»
	«ENDFOR»
		
	'''
	
	def newEdgeMethod(Edge e, Node source, Node target) {'''
	public «e.getCName»View  new«e.getCName»(«target.getCName»View target) {
		«Anchor.name» sourceAnchor = («Anchor.name») ((«AnchorContainer.name») this.getViewable().getPictogramElement()).getAnchors().get(0);
		«Anchor.name» targetAnchor = («Anchor.name») ((«AnchorContainer.name») target.getViewable().getPictogramElement()).getAnchors().get(0);
		
		«e.fqn» edge = 
			((«source.fqn») this.getViewable().getModelElement()).get«source.name.toFirstUpper»View().new«e.name.toFirstUpper»((«graphmodel.Node.name») target.getModelElement()).getViewable();
		
		«AddConnectionContext.name» acc = 
			new «AddConnectionContext.name»(sourceAnchor, targetAnchor);
		acc.setNewObject(edge);
		
		«CincoAbstractAddFeature.name» af = 
			(«CincoAbstractAddFeature.name») getFeatureProvider().getAddFeature(acc);
			
		if (af.canAdd(acc)) {
			«PictogramElement.name» pe = getFeatureProvider().addIfPossible(acc);
			if (pe instanceof «Connection.name») {
				C«e.name.toFirstUpper» cEdge = new C«e.name.toFirstUpper»();
				cEdge.setModelElement(edge);
				cEdge.setPictogramElement((«Connection.name») pe);
				this.getViewable().getCRootElement().getMap().put(edge, cEdge);
				return cEdge.get«e.getCName»View();
			}
		}
		throw new «RuntimeException.name»("No PictogrammElement created for: "+ edge);
	}
	
	'''
	}
	
	override canMoveToContainer(Node n)'''
«««	public boolean canMoveTo(«CModelElementContainerView.name» container) {
«««		«graphmodel.Node.name» node = («graphmodel.Node.name») this.getViewable().getModelElement();
«««		if (container instanceof «CGraphModelView.name») {
«««			return ((«CGraphModelView.name») container).getModelElement().canContain(node.getClass());
«««		}
«««	
«««		if (container instanceof «CContainerView.name») {
«««			return ((«Container.name») ((«CContainerView.name») container).getModelElement()).canContain(node.getClass());
«««		}
«««		return false;
	}
	'''
	
	override moveToContainer(Node n) '''
«««	public void moveTo(«CModelElementContainerView.name» container) {
«««		«n.fqn» me = («n.fqn») getViewable().getModelElement();
«««		«CModelElementContainer.name» cMEC = this.getViewable().getContainer();
«««		«ContainerShape.name» source = null, target = null;
«««		«ModelElementContainerView.name» mecv = null;
«««		if (cMEC instanceof «CGraphModel.name») 
«««			source = ((«CGraphModel.name») cMEC).getPictogramElement();
«««		
«««		if (cMEC instanceof «CContainer.name»)
«««			source = («ContainerShape.name») ((«CContainer.name») cMEC).getPictogramElement();
«««		
«««		if (container instanceof «CGraphModelView.name») {
«««			target = ((«CGraphModelView.name») container).getDiagram();
«««			mecv = ((«CGraphModelView.name») container).getViewable().getModelElement().getGraphModelView();
«««		}
«««		
«««		if (container instanceof «CContainerView.name») {
«««			target = («ContainerShape.name») ((«CContainerView.name») container).getViewable().getPictogramElement();
«««			mecv = ((«Container.name») ((«CContainerView.name») container).getViewable().getModelElement()).getContainerView();
«««		}
«««		
«««		me.getNodeView().moveTo(mecv,0,0);
«««		«CincoMoveShapeFeature.name» mf = 
«««			new «CincoMoveShapeFeature.name»(getFeatureProvider());
		
		«MoveShapeContext.name» mc = 
			new «MoveShapeContext.name»((«Shape.name») getViewable().getPictogramElement());
			
		«IMoveShapeFeature.name» mf = getFeatureProvider().getMoveShapeFeature(mc);
			
		mc.setLocation(0,0);
		mc.setSourceContainer(source);
		mc.setTargetContainer(target);
		if (mf.canMoveShape(mc))
			mf.moveShape(mc);
	}
	'''
	
	override moveToContainerXY(Node n) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override moveToXY(Node n) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def moveToMethod(Node n, ContainingElement ce)'''
	public boolean canMoveTo(«ce.getCName» container) {
		//TODO: call canMoveTo of new api
		«n.fqn» me = («n.fqn») getViewable().getModelElement();
		«IF ce instanceof NodeContainer»
		return me.getNodeView().canMoveTo(((«ce.fqn») container.getModelElement()).getContainerView());
		«ENDIF»
		«IF ce instanceof GraphModel»
		return me.getNodeView().canMoveTo(((«ce.fqn») container.getModelElement()).getGraphModelView());
		«ENDIF»
		//super.canMoveTo(container);
	}
	
	public void moveTo(«ce.getCName» container, int x, int y) {
		«n.fqn» me = («n.fqn») getViewable().getModelElement();
		«CModelElementContainer.name» cMEC = this.getViewable().getContainer();
		«ContainerShape.name» source = null, target = null; 
		if (cMEC instanceof «CGraphModel.name») 
			source = ((«CGraphModel.name») cMEC).getPictogramElement();
		
		if (cMEC instanceof «CContainer.name»)
			source = («ContainerShape.name») ((«CContainer.name») cMEC).getPictogramElement();
		
		target = («ContainerShape.name») container.getPictogramElement();
		
		«IF ce instanceof NodeContainer»
		me.getNodeView().moveTo(((«fqn(ce as NodeContainer)») container.getModelElement()).getContainerView(), x, y);
		«ELSEIF ce instanceof GraphModel»
		me.getNodeView().moveTo(((«fqn(ce as GraphModel)») container.getModelElement()).getGraphModelView(), x, y);
		«ENDIF»
		// TODO: Execute the MoveFeature...
		
		«MoveShapeContext.name» mc = 
			new «MoveShapeContext.name»((«Shape.name») getViewable().getPictogramElement());
			
		«IMoveShapeFeature.name» mf = getFeatureProvider().getMoveShapeFeature(mc);
			
		mc.setLocation(x,y);
		mc.setSourceContainer(source);
		mc.setTargetContainer(target);
		if (mf.canMoveShape(mc))
			mf.moveShape(mc);
	}
	''' 		
	
	def cloneMethod(Node n, ContainingElement nc)
	'''	public boolean canClone(«nc.getCName» container) {
		«n.fqn» me = («n.fqn») getViewable().getModelElement();
		return me.get«n.name.toFirstUpper»View().canClone(container.getModelElement());
		//super.canClone(container);
	}
	
	public void clone(«nc.getCName» container) {
		super.clone(container);
	}
	'''
	
	def canNewMethod(NodeContainer nc, Node n) '''
	public boolean canNew«n.getCName»() {
		return ((«nc.fqn») this.getModelElement()).get«nc.name.toFirstUpper»View().canNew«n.name.toFirstUpper»();
	}
	'''
	
	def newNodeMethod(NodeContainer nc, Node n) 
	'''	public «n.getCName»View new«n.getCName»(final int x, final int y) {
		return new«n.getCName»(x,y,-1,-1);
	}
	
	public «n.getCName»View new«n.getCName»(final int x, final int y, final int width, final int height) {
		«fqn(nc as Type)» cont = («fqn(nc as Type)») this.getViewable().getModelElement();
		«n.fqn» me = cont.get«nc.name.toFirstUpper»View().new«n.name.toFirstUpper»(x, y, width, height).getViewable();
		
		«AddContext.name» ac = new «AddContext.name»();
		ac.setTargetContainer((«ContainerShape.name»)this.getViewable().getPictogramElement());
		ac.setNewObject(me);
		ac.setLocation(x, y);
		ac.setSize(width, height);
		
		«IAddFeature.name» af = getFeatureProvider().getAddFeature(ac);
		«PictogramElement.name» pe = null;
		if (af.canAdd(ac)){
			pe = af.add(ac);
		}
		
		if (pe == null) 
			throw new «RuntimeException.name»("Failed to create PE for: " +af);
		«n.getCName» cNode = new «n.getCName»();
		cNode.setModelElement(me);
		cNode.setPictogramElement(pe);
		getViewable().getModelElements().add(cNode);
		getViewable().getMap().put(me, cNode);
		
		return cNode.get«n.getCName»View();
	}
	
	
	'''
	
}
