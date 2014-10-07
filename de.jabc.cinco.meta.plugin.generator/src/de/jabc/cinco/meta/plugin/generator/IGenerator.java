package de.jabc.cinco.meta.plugin.generator;

import graphmodel.GraphModel;

import org.eclipse.core.resources.IFile;

public interface IGenerator {
	public void generate(GraphModel graphModel,IFile outlet);
}
