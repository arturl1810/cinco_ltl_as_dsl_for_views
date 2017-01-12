package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class JointTracerExceptionTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "JointTracerException.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.utils;
	
	import java.util.LinkedList;
	import java.util.List;
	
	public final class JointTracerException extends Exception{
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		private List<String> messages;
		
		public JointTracerException()
		{
			messages = new LinkedList<String>();
		}
		
		public JointTracerException(List<String> s)
		{
			messages = s;
		}
	
		public final List<String> getMessages() {
			return messages;
		}
	
		public final void setMessages(List<String> messages) {
			this.messages = messages;
		}
		
		
	}
	
	'''
	
}