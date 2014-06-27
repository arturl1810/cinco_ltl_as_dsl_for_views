package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import graphmodel.ModelElement;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.ICustomContext;
import org.eclipse.graphiti.features.custom.AbstractCustomFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public abstract class CincoCustomFeature<T extends ModelElement> extends AbstractCustomFeature {

	public CincoCustomFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
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
		if (o instanceof ModelElement)
			modelElement = (T) o;
		return canExecute(modelElement); 
	}
	
	@Override
	public void execute(ICustomContext context) {
		if (canExecute(context)) {
			T modelElement = (T) getBusinessObjectForPictogramElement(context.getPictogramElements()[0]);
			execute(modelElement);
		}
	}
	
	public abstract boolean canExecute(T modelElement);
	public abstract void execute(T modelElement);

}
