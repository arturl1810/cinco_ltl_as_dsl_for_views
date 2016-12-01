package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class AbstractRunnerTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».extension;
	
	import java.util.Arrays;
	import java.util.Collections;
	import java.util.LinkedList;
	import java.util.List;
	import java.util.stream.Collectors;
	
	import org.eclipse.swt.widgets.Shell;
	
	import de.jabc.cinco.meta.core.utils.job.JobFactory;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».runner.model.ExceptionRunLog;
	import «graphmodel.tracerPackage».runner.model.MessageRunLog;
	import «graphmodel.tracerPackage».runner.model.Run;
	import «graphmodel.tracerPackage».runner.model.RunCallback;
	import «graphmodel.tracerPackage».runner.model.RunLog;
	import «graphmodel.tracerPackage».runner.model.RunResult;
	import «graphmodel.tracerPackage».runner.model.RunStepper;
	import «graphmodel.tracerPackage».stepper.model.Stepper;
	import «graphmodel.tracerPackage».stepper.model.Thread;
	import «graphmodel.tracerPackage».stepper.utils.JointTracerException;
	
	/**
	 * The abstract runner class defines an extension point class
	 * which can be used to define a Runner.
	 * A Runner describes a bunch of different execution runs.
	 * Every run is given by a context, a semantic and a model which will
	 * be executed.
	 * @author zweihoff
	 *
	 */
	public abstract class AbstractRunner {
	
		/**
		 * The start runner method starts the Runner for a given model.
		 * The shell is used, if the context initialization requires user interaction.
		 * The runnable callback method is called when all runs has ended.
		 * 
		 * The getRuns method, which is to be overridden, is used to receive all runs of this 
		 * Runner implementation.
		 * @param shell
		 * @param graph
		 * @param callback
		 */
		public final void startRunner(Shell shell,LTSMatch matchGraph,RunCallback callback)
		{
			// receive runs
			List<Run> runs = getRuns(matchGraph);
			
			List<RunStepper> runSteppers = new LinkedList<RunStepper>();
			
			//prepare the runs
			//create a semantic and a context for each run
			//initialize the context
			for(Run r:runs){
				// determine the context for each run
				AbstractContext context = r.getContext();
				// initialize the context
				// HINT: may take user interaction and blocks the UI
				context.initialize(shell);
				// receive the semantics for this run
				AbstractSemantic semantic = r.getSemantic();
				// create the stepper
				Stepper stepper = new Stepper(matchGraph,r.getStartingElements(),shell,context,semantic);
				// and combine it with the run 
				runSteppers.add(new RunStepper(r,stepper));
			}
			
			long startTime = System.nanoTime();
			System.err.println("Starting at: "+startTime);
			
			// asynchronously and in parallel concurrent execution
			// of each run stepper
			
			JobFactory.job("Executing Runner")
					.consumeConcurrent(runSteppers.size(), "executing...")
					// for each run stepper, the execute run method is called
					// which executes the entire run
				    .taskForEach(() -> runSteppers.stream(), this::executeRun)
					.onCanceledShowMessage("Runner Execution has been canceled")
					.onFinished(() -> System.err.println("Time to finfish all runs: "+(System.nanoTime()-startTime)*Math.pow(10,-9)/60))
					.onFinishedShowMessage("Runner Execution completed successfully")
					// when all run execute run methods has terminated
					// the given callback runnable is called
					.onDone(() -> this.onDone(runSteppers,callback))
					.schedule();
			
		}
		
		/**
		 * The on done method summarizes the results finihsed execution of
		 * all run steppers and finally calls the runnable callback.
		 * @param runSteppers
		 * @param runnable
		 */
		private void onDone(List<RunStepper> runSteppers,RunCallback runnable)
		{
			// trigger hook
			postAllRunsTerminated();
			//divide the run steppers depedned on their status
			List<RunStepper> active = runSteppers.stream().filter(n->n.isActive()).collect(Collectors.toList());
			List<RunStepper> inactive = runSteppers.stream().filter(n->!n.isActive()).collect(Collectors.toList());
			
			System.out.println(displayResults(active, inactive));
			
			// create the run result
			RunResult rr = new RunResult();
			rr.setActiveRunSteppers(active);
			rr.setInactiveRunSteppers(inactive);
			
			// prepare the callback
			runnable.setResult(rr);
			// and execute it
			runnable.run();
		}
		
		/**
		 * Executes the given run stepper until it is terminated or interrupted
		 * by an exception
		 * @param rs
		 */
		private void executeRun(RunStepper rs)
		{
			//execute until it is terminated or interrupted
			while(true)
			{
				List<RunLog> logging = rs.getLogging();
				Stepper s = rs.getStepper();
				//hook
				logging.addAll(preStepExecution(s.getActiveThreads(),rs.getRun()));
				
				try {
					// execute step of run
					if(!s.doStep())
					{
						//Run has successfully completed a step
						logging.addAll(postStepExecution(s.getActiveThreads(),rs.getRun()));
					}
					else{
						//Stepper has terminated
						//Run is finished
						logging.addAll(postExecutionTerminated(s.getActiveThreads(),rs.getRun()));
						rs.setStatus(RunStepper.STATUS_INACTIVE);
						break;
					}
				}
				catch (JointTracerException e) {
					// interrupted by exception
					logging.add(new ExceptionRunLog(e));
					logging.addAll(postExecutionAborted(s.getActiveThreads(),rs.getRun(),e));
					System.err.println(e.getMessages());
					break;
				}
			
			}
		}
		
		/**
		 * Displays the results after all runs have terminated their execution.
		 * Shows all logging messages of all runs grouped by their status: inactive / active
		 * @param activeRunSteppers
		 * @param inactiveRunSteppers
		 * @return
		 */
		public String displayResults(List<RunStepper> activeRunSteppers,List<RunStepper> inactiveRunSteppers)
		{
			String s = "";
			s+= "Inactive:\n";
			// all inactive runs after termination
			for(RunStepper n:inactiveRunSteppers)
			{
				s += n.getRun().toString() + "\n";
				// all logging information
				for(RunLog e:n.getLogging())
				{
					s += e.toString()+"\n";
				}
			}
			s += "Active:\n";
			// all active runs after termination
			for(RunStepper n:activeRunSteppers)
			{
				s += n.getRun().toString() + "\n";
				// all logging information
				for(RunLog e:n.getLogging())
				{
					s += e.toString() + "\n";
				}
			}
			return s;
		}
		
		/**
		 * Monitoring hooks
		 */
		
		/**
		 * 
		 * @param graph
		 * @return
		 */
		public abstract List<Run> getRuns(LTSMatch graph);
		
		/**
		 * Hook
		 * Executed before each step of each run
		 * @param allThreads
		 * @param run
		 * @return
		 */
		public List<RunLog> preStepExecution(List<Thread> allThreads,Run run) {
			
			return Collections.emptyList();
		}
		
		/**
		 * Hook
		 * Executed after each step of each run
		 * @param activeThreads
		 * @param run
		 * @return
		 */
		public List<RunLog> postStepExecution(List<Thread> activeThreads,Run run) {
			return Collections.emptyList();
		}
		
		/**
		 * Hook
		 * Executed after a run has finished
		 * @param inactiveThreads
		 * @param run
		 * @return
		 */
		public List<RunLog> postExecutionTerminated(List<Thread> inactiveThreads,Run run) {
			return Arrays.asList(new MessageRunLog("Successfully completed execution"));
		}
		
		/**
		 * Hook
		 * Executed after a run is interrupted by an exception
		 * @param inactiveThreads
		 * @param run
		 * @param e
		 * @return
		 */
		public List<RunLog> postExecutionAborted(List<Thread> inactiveThreads,Run run,JointTracerException e) {
			return Arrays.asList(new MessageRunLog("Aborted execution"));
		}
		
		/**
		 * Hook
		 * Executed after all runs are finished
		 */
		public void postAllRunsTerminated() {}
		
		/**
		 * Returns the name of the runner, which is displayed in UI
		 * to be selected by the user.
		 * @return
		 */
		public String getName()
		{
			return "Abstract Runner";
		}
	}
	
	'''
	
	override fileName() {
		return "AbstractRunner.java"
	}
	
}