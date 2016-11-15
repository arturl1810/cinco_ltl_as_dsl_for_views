package de.jabc.cinco.meta.plugin.generator.runtime;

import graphmodel.GraphModel;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import de.jabc.cinco.meta.core.utils.job.CompoundJob;

public interface IGenerator<T extends GraphModel>{
	/**
	 *
	 * @param graphModel : Graph model for which code is to be generated.
	 * @param outlet : Path to given outlet. When generate is called, existence of path is  guaranteed
	 * If Exception occurs, RuntimeException may be thrown
	 */ 
	public void generate(T graphModel, IPath outlet, IProgressMonitor monitor);

	default void collectTasks(T graphModel, IPath outlet, CompoundJob job) {
		job.consume(100).task("Generating...",
				() -> generate(graphModel, outlet, new NullProgressMonitor()));
	}
}
