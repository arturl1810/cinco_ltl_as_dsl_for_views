package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class RunTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Run.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».runner.model;
	
	import java.util.List;
	
	import «graphmodel.tracerPackage».extension.AbstractContext;
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	import «graphmodel.tracerPackage».match.model.Match;
	
	/**
	 * Compound class to store information needed for one run.
	 * A run is defined by a name for the visual representation
	 * as well as the semantic, context and the elements to start
	 * the run from.
	 * @author zweihoff
	 *
	 */
	public final class Run {
		
		private String name;
		
		private List<Match> startingElements;
		
		private AbstractSemantic semantic;
		
		private AbstractContext context;
		
		public Run(List<Match> startingElements,AbstractSemantic semantic,AbstractContext context,String name)
		{
			this.startingElements = startingElements;
			this.context = context;
			this.semantic = semantic;
			this.name = name;
		}
	
		public final List<Match> getStartingElements() {
			return startingElements;
		}
	
		public final void setStartingElements(List<Match> startingElements) {
			this.startingElements = startingElements;
		}
	
		public final AbstractSemantic getSemantic() {
			return semantic;
		}
	
		public final void setSemantic(AbstractSemantic semantic) {
			this.semantic = semantic;
		}
	
		public final AbstractContext getContext() {
			return context;
		}
	
		public final void setContext(AbstractContext context) {
			this.context = context;
		}
	
		public final String getName() {
			return name;
		}
	
		public final void setName(String name) {
			this.name = name;
		}
		
		public final String toString()
		{
			return this.name;
		}
		
	}
	
	'''
	
}