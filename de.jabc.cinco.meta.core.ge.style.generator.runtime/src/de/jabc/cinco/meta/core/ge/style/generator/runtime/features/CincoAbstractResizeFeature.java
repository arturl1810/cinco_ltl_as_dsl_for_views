package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.features.impl.DefaultResizeShapeFeature;

public class CincoAbstractResizeFeature extends DefaultResizeShapeFeature {

	private boolean apiCall = false;
	
	public CincoAbstractResizeFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canResizeShape(IResizeShapeContext context) {

		return apiCall;

	}
	
	@Override
	public void resizeShape(IResizeShapeContext context) {
		// TODO Auto-generated method stub
		super.resizeShape(context);
	}
	
	public void activateApiCall(boolean activate) {
		apiCall = activate;
	}
	
	public boolean isApiCall() {
		return apiCall;
	}
}
