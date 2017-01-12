package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ThreadStepResultTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ThreadStepResult.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	
	/**
	 * Compound class to store a step result in combination
	 * with their step
	 * @author zweihoff
	 *
	 */
	public final class ThreadStepResult {
		
		private StepResult stepResult;
		private Thread thread;
		
		public StepResult getStepResult() {
			return stepResult;
		}
		public final void setStepResult(StepResult stepResult) {
			this.stepResult = stepResult;
		}
		public final Thread getThread() {
			return thread;
		}
		public final void setThread(Thread thread) {
			this.thread = thread;
		}
		
	}
	
	'''
	
}