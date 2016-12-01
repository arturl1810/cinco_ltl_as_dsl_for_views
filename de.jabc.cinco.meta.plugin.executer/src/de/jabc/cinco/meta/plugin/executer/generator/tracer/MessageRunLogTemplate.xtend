package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class MessageRunLogTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "MessageRunLog.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	/**
	 * Run log entry to store a single string message
	 * @author zweihoff
	 *
	 */
	public class MessageRunLog implements RunLog {
		private String message;
		
		public MessageRunLog(String message)
		{
			this.message = message;
		}
	
		public String getMessage() {
			return message;
		}
	
		public void setMessage(String message) {
			this.message = message;
		}
		
		public String toString()
		{
			return message;
		}
	}
	
	'''
	
}