package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import graphmodel.ModelElement;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.impl.AbstractCreateConnectionFeature;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;
import org.eclipse.graphiti.mm.pictograms.Connection;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoEdgeCardinalityInException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoInvalidContainerException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoInvalidSourceException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.CincoInvalidTargetException;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.errorhandling.ECincoError;

public abstract class CincoCreateEdgeFeature<T extends ModelElement> extends AbstractCreateConnectionFeature{

	public static int index = 0;
	
	T newModelElement;
	protected ECincoError error = ECincoError.OK;
	
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
	
	public void throwException(ICreateConnectionContext context) {
		canCreate(context);
		Object source = context.getSourcePictogramElement().getLink().getBusinessObjects().get(0);
		Object target = context.getTargetPictogramElement().getLink().getBusinessObjects().get(0);
		
		switch (error) {
		case INVALID_SOURCE:
			throw new CincoInvalidSourceException(String.format("Invalid Source: Cannot create %s with %s as source node", getName(), source));
		case INVALID_TARGET:
			throw new CincoInvalidTargetException(String.format("Invalid Target: Cannot create %s with %s as target node", getName(), target));
		case MAX_IN:
			throw new CincoEdgeCardinalityInException(String.format("Incoimg edge cardinality exception: Node %s can not have more incoming %s-edges", getName(), target));
		case MAX_OUT:
			throw new CincoEdgeCardinalityInException(String.format("Outgoing edge cardinality exception: Node %s can not have more outgoing %s-edges", getName(), source));
		default:
			break;
		}
	} 
	
}
