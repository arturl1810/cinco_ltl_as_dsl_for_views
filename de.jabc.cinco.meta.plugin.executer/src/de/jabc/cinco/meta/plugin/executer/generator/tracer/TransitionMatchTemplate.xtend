package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class TransitionMatchTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "TransitionMatch.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.model;
	
	public class TransitionMatch extends Match{
		
		private StateMatch source;
		private StateMatch target;
		
		public TransitionMatch(Match match) {
			super(match);
		}
		public StateMatch getSource() {
			return source;
		}
		public void setSource(StateMatch source) {
			this.source = source;
		}
		public StateMatch getTarget() {
			return target;
		}
		public void setTarget(StateMatch target) {
			this.target = target;
		}
		
		
	}
	
	'''
	
}