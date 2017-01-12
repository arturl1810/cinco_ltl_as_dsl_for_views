package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class UnexpectedTerminationException extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "UnexpectedTerminationException.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.utils;
	
	public final class UnexpectedTerminationException extends TracerException {
	
		/**
		 * 
		 */
		private static final long serialVersionUID = 2L;
	
		public UnexpectedTerminationException(String text) {
			super(text);
		}
	
	}
	
	'''
	
}