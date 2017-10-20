package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import graphmodel.ModelElement;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;

public abstract class CincoCreateEdgeFeature<T extends ModelElement> extends AbstractCreateConnectionFeature{

	public static int index = 0;
	
	T newModelElement;
	
	public CincoCreateEdgeFeature(IFeatureProvider fp, String name, String description) {
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
	
	public abstract boolean canCreate(ICreateConnectionContext context, boolean apiCall);
	
}
