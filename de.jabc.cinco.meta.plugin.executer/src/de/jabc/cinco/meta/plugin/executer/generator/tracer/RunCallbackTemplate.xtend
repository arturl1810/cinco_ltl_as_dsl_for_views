package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class RunCallbackTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "RunCallback.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	/**
	 * Runnable class to execute the callback
	 * after all runs of a runner has ended.
	 * The run callback stores the run result,
	 * which can then be accessed in the run method.
	 * @author zweihoff
	 *
	 */
	public abstract class RunCallback implements Runnable {
	
		private RunResult result;
		
		public final RunResult getResult() {
			return result;
		}
	
		public final void setResult(RunResult result) {
			this.result = result;
		}
	}
	
	'''
	
}