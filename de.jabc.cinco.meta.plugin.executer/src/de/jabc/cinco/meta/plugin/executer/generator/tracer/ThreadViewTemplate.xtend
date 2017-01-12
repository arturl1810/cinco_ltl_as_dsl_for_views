package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ThreadViewTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ThreadView.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».views;
	
	import org.eclipse.jface.viewers.TableViewer;
	
	/**
	 * Combines a table view of one thread
	 * and the current mode: History, Level or Current
	 * @author zweihoff
	 *
	 */
	public final class ThreadView {
		private TableViewer viewer;
		private int currentMode;
		
		
		public final TableViewer getViewer() {
			return viewer;
		}
		public final void setViewer(TableViewer viewer) {
			this.viewer = viewer;
		}
		public final int getCurrentMode() {
			return currentMode;
		}
		public final void setCurrentMode(int currentMode) {
			this.currentMode = currentMode;
		}
		
		
	}
	
	'''
	
}