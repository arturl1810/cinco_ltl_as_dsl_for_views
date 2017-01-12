package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class RunLogTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "RunLog.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	/**
	 * Interface for a log entry, returned from
	 * one of the abstract runner hooks.
	 * 
	 * Every log run log has to implement the toString
	 * method, since it will used to display the log
	 * entry after the execution of the run.
	 * @author zweihoff
	 *
	 */
	public interface RunLog {
		public abstract String toString();
	}
	
	'''
	
}