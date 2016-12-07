package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class StepperTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Stepper.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	import java.util.Arrays;
	import java.util.LinkedList;
	import java.util.List;
	
	import org.eclipse.swt.widgets.Shell;
	
	import «graphmodel.tracerPackage».extension.AbstractContext;
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».stepper.utils.JointTracerException;
	import «graphmodel.tracerPackage».stepper.utils.TracerException;
	import «graphmodel.tracerPackage».stepper.utils.WaitingException;
	/**
	 * The main class for the execution of a model.
	 * A single execution step for all active threads in parallel can be triggered 
	 * @author zweihoff
	 *
	 */
	public final class Stepper {
		private List<Thread> activeThreads;
		private AbstractSemantic semantic;
		
		/**
		 * Initializes the context
		 * and determines all initial modelelements in the graphmodel
		 * and creates a new thread for each of them
		 * @param firstGraph
		 * @param shell
		 * @param context
		 * @param semantic
		 */
		public Stepper(LTSMatch firstGraph, Shell shell, AbstractContext context, AbstractSemantic semantic)
		{
			this(firstGraph,null,shell,context,semantic);
		}
		
		public Stepper(LTSMatch firstGraph,List<Match> startingElements, Shell shell, AbstractContext context, AbstractSemantic semantic)
		{
			this.semantic = semantic;
			activeThreads = new LinkedList<Thread>();
			
			// initialize the context
			context.initialize(shell);
			
			//Get starting element
			if(startingElements != null){
				for(Match cme:startingElements)
				{
					activeThreads.add(new Thread(firstGraph,cme,context,semantic));
				}
			}
			else{
				
				// ----
				for(Match cme:firstGraph.getStartStates())
				{
					activeThreads.add(new Thread(firstGraph,cme,context,semantic));
				}
				// ----
			}
			
		}
		
		/**
		 * Executes a single step of execution for each active thread
		 * Determines the next modelelements.
		 * Deactivates threads, which execution has been ended
		 * @return boolean True, if at least one thread is active. False, if all executions have ended
		 * @throws JointTracerException If an Illegal state has been reaches
		 * @throws TracerException 
		 */
		public final boolean doStep() throws JointTracerException
		{
			return doStep(null);
		}
		
		/**
		 * Executes a single step of execution for each active thread
		 * Determines the next modelelements.
		 * Deactivates threads, which execution has been ended
		 * @return boolean True, if the at least one thread is active. False, if all executions have ended
		 * @throws JointTracerException If an Illegal state has been reaches
		 * @throws TracerException 
		 */
		public final boolean doStep(Thread thread) throws JointTracerException
		{
			
			
			if(activeThreads.isEmpty()){
				return false;
			}
			//combined list of tracer exception messages for all 
			List<String> tracerExceptionMessages = new LinkedList<String>();
			
			List<Thread> inactiveThreads = new LinkedList<Thread>();
			List<ThreadStepResult> nextSteps = new LinkedList<ThreadStepResult>();
			List<Thread> executableThreads = this.activeThreads;			
			if(thread != null){
				executableThreads = Arrays.asList(thread);
			}
			//Calculate the next steps for all active Threads
			for(Thread t:executableThreads){
				try {
					ThreadStepResult tsr = t.doStep(activeThreads);
					if(tsr == null){
						inactiveThreads.add(t);
						continue;
					}
					nextSteps.add(tsr);
				}
				catch (WaitingException e)
				{
					//No next step is calculated
					System.out.println("Waiting");
				}
				catch(TracerException te)
				{
					// trigger Hook pre terminate
					semantic.preTerminateThread(t);
					inactiveThreads.add(t);
					tracerExceptionMessages.add(te.getText());
				}
			}
			
			//Check for Deadlock or Termination
			if(nextSteps.isEmpty()){
				//All Threads are deactivated before execution.
				if(inactiveThreads.size() >= activeThreads.size()){
					// if threads has been ended with an exception
					if(!tracerExceptionMessages.isEmpty()){
						throw new JointTracerException(tracerExceptionMessages);
					}
					return false;
				}
				//Not all Threads are terminated, but no one has done a step
				throw new JointTracerException(Arrays.asList("Deadlock detected"));
			}
			
			//All next steps has been calculated and can now be executed
			for(ThreadStepResult next:nextSteps)
			{
				Thread t = next.getThread();
				try {
					if(!t.executeStep(next.getStepResult(), this.activeThreads,this.semantic))
					{
						inactiveThreads.add(t);
						System.out.println("deactivate: "+t);				
					}
				} catch (TracerException e) {
					tracerExceptionMessages.add(e.getText());
				}
			}
			//Reduce active threads by inactive threads
			activeThreads.removeAll(inactiveThreads);
			
			if(!tracerExceptionMessages.isEmpty()){
				throw new JointTracerException(tracerExceptionMessages);
			}
			
			return !activeThreads.isEmpty();
		}
	
	
		public final List<Thread> getActiveThreads() {
			return activeThreads;
		}
	
	
		public final void setActiveThreads(List<Thread> activeThreads) {
			this.activeThreads = activeThreads;
		}
	
	
		public final AbstractSemantic getSemantic() {
			return semantic;
		}
	
	
		public final void setSemantic(AbstractSemantic semantic) {
			this.semantic = semantic;
		}
	
		
	}
	
	'''
	
}