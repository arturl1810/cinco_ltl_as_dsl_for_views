package de.jabc.cinco.meta.plugin.generator.runtime;

import graphmodel.GraphModel;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;

public interface IGenerator<T extends GraphModel>{
	/**
	 *
	 * @param graphModel : Graph model for which code is to be generated.
	 * @param outlet : Path to given outlet. When generate is called, existence of path is  guaranteed
	 * If Exception occurs, RuntimeException may be thrown
	 */ 
	public void generate(T graphModel,IPath outlet,IProgressMonitor monitor);
}
