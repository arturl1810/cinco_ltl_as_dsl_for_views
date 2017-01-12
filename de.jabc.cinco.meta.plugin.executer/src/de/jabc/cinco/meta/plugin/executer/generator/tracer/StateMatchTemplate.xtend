package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class StateMatchTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "StateMatch.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	public class StateMatch extends Match{
		
		private List<TransitionMatch> incoming;
		private List<TransitionMatch> outgoing;
		
		
		public StateMatch()
		{
			super();
			this.incoming = new LinkedList<TransitionMatch>();
			this.outgoing = new LinkedList<TransitionMatch>();
		}
		
		public StateMatch(Match matchPattern) {
			super(matchPattern);
			this.incoming = new LinkedList<TransitionMatch>();
			this.outgoing = new LinkedList<TransitionMatch>();
		}
	
		public List<TransitionMatch> getIncoming() {
			return incoming;
		}
		public void setIncoming(List<TransitionMatch> incoming) {
			this.incoming = incoming;
		}
		public List<TransitionMatch> getOutgoing() {
			return outgoing;
		}
		public void setOutgoing(List<TransitionMatch> outgoing) {
			this.outgoing = outgoing;
		}
		
	}
	
	'''
	
}