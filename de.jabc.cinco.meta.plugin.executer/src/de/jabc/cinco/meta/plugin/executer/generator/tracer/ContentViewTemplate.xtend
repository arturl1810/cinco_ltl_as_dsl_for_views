package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ContentViewTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ContentView.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».stepper.utils;
	
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».stepper.model.Thread;
	
	/**
	 * Class for combining a thread, their current element
	 * and a thread label for visualization in the tracer view
	 * @author zweihoff
	 *
	 */
	public final class ContentView {
		private String label;
		private Match element;
		private Thread thread;
		
		public ContentView(String s,Match element,Thread thread)
		{
			this.label=s;
			this.element=element;
			this.thread = thread;
		}
		
		public final String toString()
		{
			return label;
		}
	
		public final String getLabel() {
			return label;
		}
	
		public final void setLabel(String label) {
			this.label = label;
		}
	
		public final Match getElement() {
			return element;
		}
	
		public final void setElement(Match element) {
			this.element = element;
		}
	
		public final Thread getThread() {
			return thread;
		}
	
		public final void setThread(Thread thread) {
			this.thread = thread;
		}
		
		public final void flashElement()
		{
			this.thread.getHighlighter().flashElement(this.element);
		}
		
		
	}
	
	'''
	
}