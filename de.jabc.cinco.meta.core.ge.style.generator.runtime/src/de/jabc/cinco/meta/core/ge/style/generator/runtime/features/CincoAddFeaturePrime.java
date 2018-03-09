package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.context.impl.CreateContext;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.createfeature.CincoCreateFeature;

public class CincoAddFeaturePrime extends CincoAddFeature {

	protected CincoCreateFeature createFeature;
	
	public CincoAddFeaturePrime(IFeatureProvider fp) {
		super(fp);
	}

	public void throwException(IAddContext ac) {
		CreateContext cc = new CreateContext();
		cc.setHeight(ac.getHeight());
		cc.setWidth(ac.getWidth());
		cc.setX(ac.getX());
		cc.setY(ac.getY());
		cc.setTargetContainer(ac.getTargetContainer());
		createFeature.canCreate(cc);
		createFeature.throwException(cc);
	}
}
