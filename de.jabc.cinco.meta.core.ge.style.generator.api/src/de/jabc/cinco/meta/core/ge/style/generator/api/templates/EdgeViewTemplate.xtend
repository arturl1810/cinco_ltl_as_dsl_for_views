package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import graphicalgraphmodel.CNode
import mgl.Edge
import mgl.ModelElement

class EdgeViewTemplate extends ModelElementTemplate{
	
	new(ModelElement me) {
		super(me)
	}
	
	def sourceGetter(Edge edge)'''
	«var sources = edge.possibleSources»
	«IF sources.size == 1»
	public «sources.get(0).fqcn» getSource() {
		return («sources.get(0).fqcn») getViewable().getSourceElement();
	}
	«ELSE»
	public «CNode.name» getSource() {
		return getViewable().getSourceElement();
	}
	«ENDIF»
	'''
	
	
	def targetGetter(Edge edge)'''
	«var targets = edge.possibleTargets»
	«IF targets.size == 1»
	public «targets.get(0).fqcn» getTarget() {
		return («targets.get(0).fqcn») getViewable().getTargetElement();
	}
	«ELSE»
	public «CNode.name» getTarget() {
		return getViewable().getTargetElement();
	}
	«ENDIF»
	'''

	def reconnectSource(Edge edge)'''
	«var sources = edge.possibleSources»
	«FOR s : sources»
	/*public boolean canReconnectSource(«s.fqcn» source) {
		return ((«edge.fqn») getViewable().getModelElement()).getEdgeView().canReconnectSource(source.getModelElement());
	}
	
	public void reconnectSource(«s.fqcn» source) {
		((«edge.fqn») getViewable().getModelElement()).getEdgeView().reconnectSource(source.getModelElement());
		// TODO: do the awesome graphiti reconnect stuff.
	}*/
	
	«ENDFOR»
	'''
	
	def reconnectTarget(Edge edge)'''
	«var targets = edge.possibleTargets»
	«FOR s : targets»
	/*public boolean canReconnectTarget(«s.fqcn» target) {
		//return ((«edge.fqn») getViewable().getModelElement()).getEdgeView().canReconnectTarget(target.getModelElement());
	}*/
	
	/*public void reconnectTarget(«s.fqcn» target) {
		((«edge.fqn») getViewable().getModelElement()).getEdgeView().reconnectTarget(target.getModelElement());
		// TODO: do the awesome graphiti reconnect stuff.
	}*/
	
	«ENDFOR»
	''' 

	def viewableGetter(Edge e)'''
	public «e.fqcn» getViewable() {
		return this.viewable;
	}
	'''
	
	def viewableSetter(Edge e)'''
	public void  setViewable(«e.fqcn» cEdge) {
		this.viewable = cEdge;
	}
	'''

}
