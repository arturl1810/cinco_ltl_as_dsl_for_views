package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class AbstractSemanticTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "AbstractSemantic.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».extension;
	
	import java.util.List;
	import java.util.stream.Collectors;
	
	import «graphmodel.CApiPackage».CDefault;
	import «graphmodel.CApiPackage».CInitializing;
	import «graphmodel.CApiPackage».CTerminating;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.StateMatch;
	import «graphmodel.tracerPackage».match.model.TransitionMatch;
	import «graphmodel.tracerPackage».stepper.model.Level;
	import «graphmodel.tracerPackage».stepper.model.NextTransition;
	import «graphmodel.tracerPackage».stepper.model.StepResult;
	import «graphmodel.tracerPackage».stepper.model.StepType;
	import «graphmodel.tracerPackage».stepper.model.Thread;
	import «graphmodel.tracerPackage».stepper.utils.TracerException;
	import «graphmodel.tracerPackage».stepper.utils.WaitingException;
	
	/**
	 * The abstract semantic defines an extension point for the semantic
	 * of a given tracer. Multiple semantic implementations can be applied
	 * to a tracer.
	 * 
	 * The semantic provides methods to decide which transition shouls be taken
	 * and what should happen on a transition.
	 * 
	 * In addition to this, multiple hooks can be used for i.e. logging
	 * @author zweihoff
	 *
	 */
	public abstract class AbstractSemantic {
		
		/**
		 * After the calculation of a possible step, the step is executed on the model
		 * This includes the setting of a new current element.
		 * @param stepResult
		 * @return
		 * @throws TracerException
		 */
		public final StepResult doPostProcessingStep(StepResult stepResult,AbstractContext context) throws TracerException
		{
			// get the element which should be the next current element
			Match element = stepResult.getFollowingElement();
			
			// hooks
			// is a state
			if(element instanceof StateMatch){
				if(element.getPattern() instanceof CInitializing){
					this.postExecuteStartStateHook((StateMatch) element, context);
				}
				if(element.getPattern() instanceof CDefault){
					this.postExecuteDefaultStateHook((StateMatch)element, context);
				}
				if(element.getPattern() instanceof CTerminating){
					this.postExecuteTerminatingStateHook((StateMatch)element, context);
				}
			}
			
			//New Level State
			if(element.getLevel() != null){
				//if container has interlevel state
				//get start of container
				LTSMatch nextLevel = element.getLevel();
				List<StateMatch> startStates = nextLevel.getStartStates();
				if(startStates.isEmpty()){
					throw new TracerException("No Start State found in "+this.displayLevel(nextLevel));
				}
				StateMatch startState = startStates.get(0);
				
				stepResult.setPostElement(startState);
				stepResult.setNewElements(startStates.subList(1, startStates.size()));
				stepResult.setPreElement(element);
				stepResult.setStepType(StepType.Level);
				return stepResult;
			}
			
			if(element instanceof CTerminating){
				//if container has interlevel state
				//get level up
				stepResult.setStepType(StepType.Terminating);
				return stepResult;
			}
			
			return stepResult;
		}
		
		/**
		 * Determines the next and previous ModelElement which will be the current modelelement, after the execution
		 * @param element
		 * @param context
		 * @param threads
		 * @return
		 * @throws TracerException
		 * @throws WaitingException
		 */
		public final StepResult doStep(Match element,AbstractContext context,List<Thread> threads) throws TracerException, WaitingException
		{
			StepResult stepResult = new StepResult();
			stepResult.setPreElement(element);
				
			//Default State
			if(element instanceof StateMatch){
				
				NextTransition nextTransition = executeState((StateMatch) element,context,threads);
				
				if(nextTransition == null){
					return null;
				}
				
				if(nextTransition.getNextEdge() != null) {
					stepResult.setFollowingElement(nextTransition.getNextEdge());
					stepResult.setNewElements(nextTransition.getForkEdges().stream().map(n->n.getTarget()).collect(Collectors.toList()));
					stepResult.setStepType(StepType.Default);
					return stepResult;
				}
				else if(nextTransition.getForkEdges() != null){
					if(!nextTransition.getForkEdges().isEmpty())
					{
						stepResult.setFollowingElement(null);
						stepResult.setNewElements(nextTransition.getForkEdges().stream().map(n->n.getTarget()).collect(Collectors.toList()));
						stepResult.setStepType(StepType.Terminating);
						return stepResult;
					}
				}
			}
			//Default Transition
			if(element instanceof TransitionMatch){
				stepResult.setFollowingElement(executeEdge((TransitionMatch) element,context,threads));
				
				// pre state hooks
				StateMatch state = (StateMatch) stepResult.getFollowingElement();
				
				if(state.getPattern() instanceof CInitializing){
					this.preExecuteStartStateHook(state, context);
				}
				if(state.getPattern() instanceof CDefault){
					this.preExecuteDefaultStateHook(state, context);
				}
				if(state.getPattern() instanceof CTerminating){
					this.preExecuteTerminatingStateHook(state, context);
				}
				
				
				stepResult.setStepType(StepType.Default);
				return stepResult;
			}
			//Terminated
			stepResult.setStepType(StepType.Terminating);
			return stepResult;
		}
		
		/**
		 * The callback to decide which edge will be taken in this step
		 * @param state The current State
		 * @param context The context
		 * @return the next edge to be taken
		 */
		public abstract NextTransition executeState(StateMatch state,AbstractContext context,List<Thread> threads) throws TracerException;	
		
		/**
		 * The callback to be executed when an edge is taken in the next step
		 * @param edge The current Edge
		 * @param context The Abstract Context
		 */
		public StateMatch executeEdge(TransitionMatch edge,AbstractContext context,List<Thread> threads) throws TracerException
		{
			return edge.getTarget();
		}
		
		// -- STATE HOOKS
		
		/**
		 * Hook
		 * Is executed before a default state is reached
		 * @param state
		 * @param context
		 */
		public void preExecuteDefaultStateHook(StateMatch state,AbstractContext context) {}
		
		/**
		 * Hook
		 * Is executed after a default state has been reached
		 * @param state
		 * @param context
		 */
		public void postExecuteDefaultStateHook(StateMatch state,AbstractContext context) {}
		
		/**
		 * Hook
		 * Is executed before a start state is reached
		 * @param state
		 * @param context
		 */
		public void preExecuteStartStateHook(StateMatch state,AbstractContext context) {}	
		
		/**
		 * Hook
		 * Is executed after a start state has been reached
		 * @param state
		 * @param context
		 */
		public void postExecuteStartStateHook(StateMatch state,AbstractContext context) {}	
			
		/**
		 * Hook
		 * Is executed before a terminating state is reached
		 * @param state
		 * @param context
		 */
		public void preExecuteTerminatingStateHook(StateMatch state,AbstractContext context) {}
		
		/**
		 * Hook
		 * Is executed after a temrinating state is reached
		 * @param state
		 * @param context
		 */
		public void postExecuteTerminatingStateHook(StateMatch state,AbstractContext context) {}
		
		// -- THREAD HOOKS
		
		/**
		 * Hook
		 * Is executed before a new thread is spawned
		 * @param thread The spawning thread
		 */
		public void preSpawnNewThread(Thread thread) {}
		
		/**
		 * Hook
		 * Is executed after a new thread has been spawned
		 * @param thread The spawning thread
		 */
		public void postSpawnNewThread(Thread thread) {}
		
		/**
		 * Hook
		 * Is executed before a thread is terminated
		 * @param thread The spawning thread
		 */
		public void preTerminateThread(Thread thread) {}
		
		// -- LEVEL HOOKS
		
		/**
		 * Hook
		 * Is executed before a new level is reached
		 * @param thread
		 * @param level
		 */
		public void preEnterNewLevel(Thread thread,Level level) {}
		
		/**
		 * Hook
		 * Is executed after a new level has been reached
		 * @param thread
		 * @param level
		 */
		public void postEnterNewLevel(Thread thread,Level level) {}
		
		/**
		 * Hook
		 * Is executed before a level is left
		 * @param thread
		 * @param level
		 */
		public void preLeaveLevel(Thread thread,Level level) {}
		
		// -- Display
		
		/**
		 * Returns the name of the semantic.
		 * Is used to display it to the UI, so that the user can choose
		 * a semantic
		 * @return
		 */
		public abstract String getName();
			
		/**
		 * Returns the visual representation for a level
		 * @param container
		 * @return
		 */
		public abstract String displayLevel(LTSMatch container);
		
		/**
		 * Returns the visual representation for an element
		 * @param element
		 * @return
		 */
		public abstract String displayElement(Match element);
		
	}	
	'''
	
}