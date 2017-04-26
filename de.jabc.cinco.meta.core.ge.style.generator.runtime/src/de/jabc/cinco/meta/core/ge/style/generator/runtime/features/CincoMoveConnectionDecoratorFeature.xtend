package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalEdge
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IMoveConnectionDecoratorContext
import org.eclipse.graphiti.features.impl.DefaultMoveConnectionDecoratorFeature
import org.eclipse.graphiti.services.Graphiti
import graphmodel.internal.InternalFactory

class CincoMoveConnectionDecoratorFeature extends DefaultMoveConnectionDecoratorFeature {
	
	new(IFeatureProvider fp) {
		super(fp) 
	}
	
	override canMoveConnectionDecorator(IMoveConnectionDecoratorContext context) {
		super.canMoveConnectionDecorator(context)
	}

	override moveConnectionDecorator(IMoveConnectionDecoratorContext context) {
		super.moveConnectionDecorator(context)
		val cd = context.connectionDecorator
		val i = Integer.parseInt(Graphiti::peService.getPropertyValue(cd, "cdIndex"))
		var edge = getBusinessObjectForPictogramElement(cd) as InternalEdge;
		val _d = edge.decorators.get(i)
		_d.locationShift = InternalFactory.eINSTANCE.create_Point => [x = context.x; y= context.y]
	}
	
}
