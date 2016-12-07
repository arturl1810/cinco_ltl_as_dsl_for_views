package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class NextTransitionTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "NextTransition.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	import «graphmodel.tracerPackage».match.model.TransitionMatch;
	/**
	 * A container class for the next edge to be the current element
	 * and a list of edges which will spawn new threads to hold the new execution control flows
	 * @author zweihoff
	 *
	 */
	public final class NextTransition {
		private TransitionMatch nextEdge;
		private List<TransitionMatch> forkEdges;
		
		public NextTransition()
		{
			this.forkEdges = new LinkedList<TransitionMatch>();
		}
		
		public final TransitionMatch getNextEdge() {
			return nextEdge;
		}
		public final void setNextEdge(TransitionMatch nextEdge) {
			this.nextEdge = nextEdge;
		}
		public final List<TransitionMatch> getForkEdges() {
			return forkEdges;
		}
		public final void setForkEdges(List<TransitionMatch> forkEdges) {
			this.forkEdges = forkEdges;
		}
		
		
	}
	
	'''
	
}