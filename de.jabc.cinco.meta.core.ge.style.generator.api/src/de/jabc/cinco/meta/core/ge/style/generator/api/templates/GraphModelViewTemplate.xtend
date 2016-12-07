package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import mgl.GraphModel
import mgl.Node
import org.eclipse.graphiti.features.IAddFeature
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import de.jabc.cinco.meta.core.ge.style.generator.api.utils.APIUtils

class GraphModelViewTemplate extends APIUtils{
	
	var GraphModel gm
	
	new (GraphModel gm) {
		this.gm = gm;
	}
	
	def viewableGetter(GraphModel gm)'''
	public «gm.fqcn» getViewable(){
		return this.viewable;
	}
	'''
	
	def viewableSetter(GraphModel gm)'''
	public void setViewable(«gm.fqcn» cNode) {
		this.viewable = cNode;
	}
	'''
	
	def canNewMethod(GraphModel gm, Node n) '''
	public boolean canNew«n.getCName»() {
		return ((«gm.fqn») this.getModelElement()).get«gm.name.toFirstUpper»View().canNew«n.name.toFirstUpper»();
	}
	'''
	
	def newNodeMethod(GraphModel gm, Node n)'''	
	public «n.getCName»View new«n.getCName»(final int x, final int y) {
		return new«n.getCName»(x,y,-1,-1);
	}
	
	public «n.getCName»View new«n.getCName»(final int x, final int y, final int width, final int height) {
		«gm.fqn» cont = («gm.fqn») this.getViewable().getModelElement();
		«n.fqn» me = cont.get«gm.name.toFirstUpper»View().new«n.name.toFirstUpper»(x, y, width, height).getViewable();
		
		«AddContext.name» ac = new «AddContext.name»();
		ac.setTargetContainer(this.getViewable().getPictogramElement());
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
