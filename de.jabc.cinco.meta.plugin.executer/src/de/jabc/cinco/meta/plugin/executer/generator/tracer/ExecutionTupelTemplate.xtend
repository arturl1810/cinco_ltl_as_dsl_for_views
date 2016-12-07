package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ExecutionTupelTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ExecutionTupel.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».handler;
	
	import «graphmodel.tracerPackage».extension.AbstractSemantic;
	import «graphmodel.tracerPackage».extension.AbstractContext;
	/**
	 * Combines the abstract semantic and context description
	 * Container class
	 * @author zweihoff
	 *
	 */
	public final class ExecutionTupel {
		private AbstractSemantic semantic;
		private AbstractContext context;
		public AbstractSemantic getSemantic() {
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
	}
	
	'''
	
}