package de.jabc.cinco.meta.core.ge.style.model.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.impl.AbstractAddFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public class CincoAbstractAddFeature extends AbstractAddFeature {

	protected boolean hook = true;
	
	public CincoAbstractAddFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canAdd(IAddContext context) {
		return false;
	}

	@Override
	public PictogramElement add(IAddContext context) {
		return null;
	}
	
	public void setHook(boolean activateHook) {
		hook = activateHook;
	}

}
