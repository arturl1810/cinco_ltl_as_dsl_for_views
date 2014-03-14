package de.jabc.cinco.meta.plugin.generator;

import org.eclipse.core.resources.IFile;
import graphmodel.GraphModel;

public interface IGenerator {
	public void generate(GraphModel graphModel,IFile outlet);
}
