package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import graphmodel.ModelElement;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;

public abstract class CincoCreateFeature<T extends ModelElement> extends AbstractCreateFeature{

	T newModelElement;
	boolean apiCall;
	
	public CincoCreateFeature(IFeatureProvider fp, String name, String description) {
		super(fp, name, description);
	}

	public T getModelElement()
	{
		return newModelElement;
	}
	
	public void setModelElement(T model)
	{
		newModelElement = model;
	}
	
	public abstract boolean canCreate(ICreateContext context, boolean apiCall);
	
}
