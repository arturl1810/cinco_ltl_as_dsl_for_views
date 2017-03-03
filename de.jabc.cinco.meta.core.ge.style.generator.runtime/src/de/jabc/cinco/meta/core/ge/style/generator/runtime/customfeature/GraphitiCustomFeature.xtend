package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import graphmodel.IdentifiableElement
import graphmodel.internal.InternalModelElement
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICustomContext
import org.eclipse.graphiti.features.custom.AbstractCustomFeature
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.services.Graphiti
import graphmodel.ModelElement

class GraphitiCustomFeature<T extends IdentifiableElement> extends AbstractCustomFeature implements ICustomFeature{
	
	private CincoCustomAction<T> delegate;
	
	new(IFeatureProvider fp) {
		super(fp)
	}
	
	new(IFeatureProvider fp, CincoCustomAction<T> cca) {
		super(fp)
		this.delegate = cca
	}
	
	override getDescription() {
		return delegate.name
	}
	
	override getName() {
		return delegate.name
	}
	
	override canExecute(ICustomContext context) {
		val pe = context.pictogramElements.get(0);
		val T bo = Graphiti.linkService.getBusinessObjectForLinkedPictogramElement(pe) as T
		switch bo {
			ModelElement : delegate.canExecute(bo as T) 
			InternalModelElement : delegate.canExecute(bo.element as T)
			default : throw new RuntimeException("Error in canExecute with element: " + bo) 
		}
	}
	
	override execute(ICustomContext context) {
		val pe = context.pictogramElements.get(0);
		val T bo = Graphiti.linkService.getBusinessObjectForLinkedPictogramElement(pe) as T
		switch bo {
			ModelElement : delegate.execute(bo as T)
			InternalModelElement : delegate.execute(bo.element as T)
			default : throw new RuntimeException("Error in canExecute with element: " + bo) 
		}
	}
	
	
}