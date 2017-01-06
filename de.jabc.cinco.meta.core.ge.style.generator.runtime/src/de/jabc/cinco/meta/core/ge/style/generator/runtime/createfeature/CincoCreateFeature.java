package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import graphmodel.ModelElement;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;

public abstract class CincoCreateFeature<T extends ModelElement> extends AbstractCreateFeature{

	T newModelElement;
	
	public CincoCreateFeature(IFeatureProvider fp, String name, String description) {
		super(fp, name, description);
		// TODO Auto-generated constructor stub
	}

	public T getModelElement()
	{
		return newModelElement;
	}
	
	public void setModelElement(T model)
	{
		newModelElement = model;
	}
	
}
