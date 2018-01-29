package de.jabc.cinco.meta.core.ge.style.generator.runtime.api;

import org.eclipse.graphiti.features.IFeatureProvider;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider;

public interface CGraphModel extends CModelElement{

	public IFeatureProvider getFeatureProvider();
	public void setFeatureProvider(IFeatureProvider fp);
	
}
