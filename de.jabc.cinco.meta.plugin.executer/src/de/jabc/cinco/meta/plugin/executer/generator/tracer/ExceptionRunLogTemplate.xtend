package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ExceptionRunLogTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ExceptionRunLog.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	import «graphmodel.tracerPackage».stepper.utils.JointTracerException;
	
	/**
	 * Run log entry to store an joint tracer exception
	 * @author zweihoff
	 *
	 */
	public class ExceptionRunLog implements RunLog {
		
		
		private JointTracerException jte;
		
		
		public ExceptionRunLog(JointTracerException e){
			this.jte = e;
		}
		
		
		public String toString()
		{
			return String.join("\n",jte.getMessages());
		}
	}
	
	'''
	
}