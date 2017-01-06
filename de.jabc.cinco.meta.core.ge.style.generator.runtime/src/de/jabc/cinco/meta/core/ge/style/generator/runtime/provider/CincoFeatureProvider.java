package de.jabc.cinco.meta.core.ge.style.generator.runtime.provider;

import org.eclipse.graphiti.features.IAddFeature;
import org.eclipse.graphiti.features.IFeature;
import org.eclipse.graphiti.features.context.IContext;

public interface CincoFeatureProvider {

	public IAddFeature[] getAllLibComponentAddFeatures();
	public Object[] executeFeature(IFeature f, IContext c);
	
}
