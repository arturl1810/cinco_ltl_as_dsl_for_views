package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature;

import graphmodel.GraphModel;
import graphmodel.ModelElement;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICustomContext;
import org.eclipse.graphiti.features.custom.AbstractCustomFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public abstract class CincoCustomAction<T extends EObject> extends AbstractCustomFeature {

	
	
	public CincoCustomAction(IFeatureProvider fp) {
		super(fp);
	}

	
	@Override
	public boolean canExecute(ICustomContext context) {
		PictogramElement[] pes = context.getPictogramElements();
		if (pes.length > 1)
			return false;
		if (pes.length == 0)
			return false;
		Object o = getBusinessObjectForPictogramElement(pes[0]);
		T modelElement = null;
		if (o instanceof ModelElement || o instanceof GraphModel)
			modelElement = (T) o;
		try {
			return canExecute(modelElement);
		} catch (ClassCastException e) {
			return false;
		}
	}
	
	@Override
	public void execute(ICustomContext context) {
		if (canExecute(context)) {
			T modelElement = (T) getBusinessObjectForPictogramElement(context.getPictogramElements()[0]);
			execute(modelElement);
		}
	}
	
	public abstract boolean canExecute(T modelElement) throws ClassCastException;
	public abstract void execute(T modelElement);

}