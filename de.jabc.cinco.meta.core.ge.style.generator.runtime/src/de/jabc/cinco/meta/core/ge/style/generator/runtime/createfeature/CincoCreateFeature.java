package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoContainerCardinalityException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoInvalidContainerException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError;
import graphmodel.ModelElement;
import graphmodel.internal.InternalNode;

public abstract class CincoCreateFeature<T extends ModelElement> extends AbstractCreateFeature{

	T newModelElement;
	boolean apiCall;
	protected ECincoError error = ECincoError.OK;
	
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
	
	public void throwException(ICreateContext context) {
		Object target = context.getTargetContainer().getLink().getBusinessObjects().get(0);
		switch (error) {
		case INVALID_CONTAINER:
			throw new CincoInvalidContainerException(
					String.format(
							"Invalid Container: Cannot create %s in container %s", getName(), target));
		case MAX_CARDINALITY:
			throw new CincoContainerCardinalityException(
					String.format(
							"Cardinality exceeded: Cannot create %s in container %s. It can't contain more elements of type %s ", 
							getName(), target,getName()));
		case INVALID_SOURCE:

		case INVALID_TARGET:

		case MAX_IN:

		case MAX_OUT:

		default:
			break;
		}
	}
	
}
