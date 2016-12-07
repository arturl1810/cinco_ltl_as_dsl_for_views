package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class StepResultTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "StepResult.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	import «graphmodel.tracerPackage».match.model.Match;
	
	/**
	 * Internal container class to store the previous and the next modelelement of
	 * one execution step. The StepType describes which kind of step will be done.
	 * The list of newElements describes modelelemets which will spawn a new thread
	 * of execution.
	 * 
	 * @author zweihoff
	 *
	 */
	public final class StepResult {
		private Match postElement;
		private Match preElement;
		private List<? extends Match> newElements;
		private StepType stepType;
	
		public StepResult() {
			this.newElements = new LinkedList<Match>();
		}
	
		public final Match getFollowingElement() {
			return postElement;
		}
	
		public final void setFollowingElement(Match followingElement) {
			this.postElement = followingElement;
		}
	
		public final StepType getStepType() {
			return stepType;
		}
	
		public final void setStepType(StepType stepType) {
			this.stepType = stepType;
		}
	
		public final List<? extends Match> getNewElements() {
			return newElements;
		}
	
		public final void setNewElements(List<? extends Match> newElements) {
			this.newElements = newElements;
		}
	
		public final Match getPostElement() {
			return postElement;
		}
	
		public final void setPostElement(Match postElement) {
			this.postElement = postElement;
		}
	
		public final Match getPreElement() {
			return preElement;
		}
	
		public final void setPreElement(Match preElement) {
			this.preElement = preElement;
		}
	
		public final String toString() {
			String label = "";
			String type = "";
			type = postElement.getPattern().getLabel();
			return type + "-" + label + ":" + stepType.toString();
		}
	
	}
	
	'''
	
}