package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class StepTypeTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "StepType.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.model;
	/**
	 * The StepType defines, whether an executionstep terminates the current thread,
	 * creates a new level or leaves the current one or is a default execution
	 * @author zweihoff
	 *
	 */
	public enum StepType {
		Default, Level, Terminating
	}
	
	'''
	
}