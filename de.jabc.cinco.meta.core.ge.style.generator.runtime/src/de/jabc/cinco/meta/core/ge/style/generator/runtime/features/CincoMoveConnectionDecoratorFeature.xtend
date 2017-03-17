package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.impl.DefaultMoveConnectionDecoratorFeature
import org.eclipse.graphiti.features.context.IMoveConnectionDecoratorContext
import graphmodel.internal.InternalEdge

class CincoMoveConnectionDecoratorFeature extends DefaultMoveConnectionDecoratorFeature {
	
	new(IFeatureProvider fp) {
		super(fp) 
	}
	
	override canMoveConnectionDecorator(IMoveConnectionDecoratorContext context) {
		super.canMoveConnectionDecorator(context)
	}

	override moveConnectionDecorator(IMoveConnectionDecoratorContext context) {
		super.moveConnectionDecorator(context)
		var edge = getBusinessObjectForPictogramElement(context.connectionDecorator) as InternalEdge;
	}
	
}
