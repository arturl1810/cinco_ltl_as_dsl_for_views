package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICustomContext
import org.eclipse.graphiti.features.custom.AbstractCustomFeature
import org.eclipse.graphiti.features.custom.ICustomFeature
import org.eclipse.graphiti.services.Graphiti

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
			InternalModelElement : delegate.canExecute(bo.element as T)
			InternalGraphModel : delegate.canExecute(bo as T)
			IdentifiableElement : delegate.canExecute(bo as T) 
			default : throw new RuntimeException("Error in canExecute with element: " + bo) 
		}
	}
	
	override execute(ICustomContext context) {
		val pe = context.pictogramElements.get(0);
		val T bo = Graphiti.linkService.getBusinessObjectForLinkedPictogramElement(pe) as T
		switch bo {
			InternalModelElement : delegate.execute(bo.element as T)
			InternalGraphModel : delegate.execute(bo.element as T)
			IdentifiableElement : delegate.execute(bo as T)
			default : throw new RuntimeException("Error in canExecute with element: " + bo) 
		}
	}
	
	
}