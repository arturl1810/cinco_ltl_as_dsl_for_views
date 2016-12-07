package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class TracerExceptionTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "TracerException.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.utils;
	
	public class TracerException extends Exception{
		/**
		 * 
		 */
		private static final long serialVersionUID = 2473594613264330405L;
		
		private String text;
		
		public TracerException(String text) {
			this.text = text;
		}
		public String getText() {
			return text;
		}
		public void setText(String text) {
			this.text = text;
		}
		public static long getSerialversionuid() {
			return serialVersionUID;
		}
		
	}
	
	'''
	
}