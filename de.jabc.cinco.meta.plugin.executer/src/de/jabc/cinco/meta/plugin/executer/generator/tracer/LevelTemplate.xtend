package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class LevelTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Level.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	import «graphmodel.tracerPackage».extension.AbstractContext;
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».stepper.utils.TracerException;
	import «graphmodel.tracerPackage».stepper.utils.WaitingException;
	/**
	 * Defines a level of execution.
	 * every time an inter- or outerlevel state is executed, a new level is created.
	 * The level contains information about the current modelelement
	 * @author zweihoff
	 *
	 */
	public final class Level {
		private LTSMatch graph;
		private Match currentElement;
		private LTSMatch currentContainer;
		private List<Match> history;
		private AbstractSemantic abstractSemantic;
		
		/**
		 * Creates a new Level.
		 * Set the first element and highlights it
		 * Initializes the history
		 * @param firstElement
		 * @param abstractSemantic
		 */
		public Level(Match firstElement,AbstractSemantic abstractSemantic,List<Match> globalHistory)
		{
			this.abstractSemantic = abstractSemantic;
			
			history = new LinkedList<Match>();
			currentElement = firstElement;
			currentContainer = firstElement.getRoot();
			graph = firstElement.getRoot();
			history.add(currentElement);
			globalHistory.add(currentElement);
			
		}
		
		/**
		 * Determines the next modelelement for this level after the execution
		 * @return StepResult The next and the previous modelelement
		 */
		public final StepResult doStep(AbstractContext context,List<Thread> threads) throws TracerException, WaitingException
		{
			return abstractSemantic.doStep(currentElement, context,threads);		
		}
		
		/**
		 * Finaly executes the StepResult and sets the new current modelelement of this level
		 * Iff the StepResult is a default execution without any level changes.
		 * @param stepResult The StepResult to be executed
		 * @param globalHistory 
		 * @return The given StepResult without changes
		 * @throws TracerException 
		 */
		public final StepResult executeStep(StepResult stepResult, List<Match> globalHistory,AbstractContext context) throws TracerException
		{
			stepResult = this.abstractSemantic.doPostProcessingStep(stepResult,context);
			if(stepResult.getStepType() == StepType.Default)
			{
				history.add(stepResult.getFollowingElement());
				globalHistory.add(stepResult.getFollowingElement());
				currentElement = stepResult.getPostElement();
			}
			else if(stepResult.getStepType() == StepType.Terminating){
				history.add(stepResult.getFollowingElement());
				globalHistory.add(stepResult.getFollowingElement());
			}
			return stepResult;
		}
		
		public final LTSMatch getGraph() {
			return graph;
		}
		public final void setGraph(LTSMatch graph) {
			this.graph = graph;
		}
		public final Match getCurrenElement() {
			return currentElement;
		}
		public final void setCurrenElement(Match currenElement) {
			this.currentElement = currenElement;
		}
		public final LTSMatch getCurrentContainer() {
			return currentContainer;
		}
		public final void setCurrentContainer(LTSMatch currentContainer) {
			this.currentContainer = currentContainer;
		}
		public final List<Match> getHistory() {
			return history;
		}
		public final void setHistory(List<Match> history) {
			this.history = history;
		}
		
		public final String toString()
		{
			return this.abstractSemantic.displayLevel(currentContainer.getContainer())+" "+this.abstractSemantic.displayElement(currentElement);
		}
	}
	
	'''
	
}