package de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature;


import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICreateContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;
import org.eclipse.graphiti.features.impl.AbstractCreateFeature;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement;
import graphmodel.ModelElement;
import graphmodel.internal.InternalNode;

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
	
	
	protected void updateContext(InternalNode _node_, CreateContext cc) {
		cc.setLocation(_node_.getX() >= 0 ? _node_.getX() : cc.getX(), _node_.getY() >= 0 ? _node_.getY() : cc.getY());
		cc.setSize(_node_.getWidth() >= 0 ? _node_.getWidth() : cc.getWidth(), _node_.getHeight() >= 0 ? _node_.getHeight() : cc.getHeight());
		PictogramElement parentContainerShape = ((CModelElement) _node_.getElement().getContainer()).getPictogramElement();
		cc.setTargetContainer((ContainerShape) parentContainerShape);
	}
}
