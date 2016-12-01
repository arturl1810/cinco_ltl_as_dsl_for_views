package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class RunResultTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "RunResult.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	import java.util.LinkedList;
	import java.util.List;
	
	/**
	 * Compound class for the active and inactive runs
	 * present for the current runner.
	 * 
	 * The run result will be created after the termination of a runner
	 * to display the results.
	 * @author zweihoff
	 *
	 */
	public final class RunResult {
		private List<RunStepper> activeRunSteppers;
		private List<RunStepper> inactiveRunSteppers;
		
		public RunResult()
		{
			this.activeRunSteppers = new LinkedList<RunStepper>();
			this.inactiveRunSteppers = new LinkedList<RunStepper>();
		}
		
		public RunResult(List<RunStepper> activeRunSteppers, List<RunStepper> inactiveRunSteppers) {
			this.activeRunSteppers = activeRunSteppers;
			this.inactiveRunSteppers = inactiveRunSteppers;
		}
	
		public final List<RunStepper> getActiveRunSteppers() {
			return activeRunSteppers;
		}
		public final void setActiveRunSteppers(List<RunStepper> activeRunSteppers) {
			this.activeRunSteppers = activeRunSteppers;
		}
		public final List<RunStepper> getInactiveRunSteppers() {
			return inactiveRunSteppers;
		}
		public final void setInactiveRunSteppers(List<RunStepper> inactiveRunSteppers) {
			this.inactiveRunSteppers = inactiveRunSteppers;
		}
		
		
	}
	
	'''
	
}