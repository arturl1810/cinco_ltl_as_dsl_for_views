package de.jabc.cinco.meta.plugin.generator;

import graphmodel.GraphModel;

import org.eclipse.core.runtime.IPath;

public interface IGenerator{
	/**
	 *
	 * @param graphModel : Graphmodel which is to be generated.
	 * @param outlet : Path to given outlet. When generate is called, existance of path is  guaranteed
	 * If Exception occurs, RuntimeException may be thrown
	 */ 
	public void generate(GraphModel graphModel,IPath outlet);
}
