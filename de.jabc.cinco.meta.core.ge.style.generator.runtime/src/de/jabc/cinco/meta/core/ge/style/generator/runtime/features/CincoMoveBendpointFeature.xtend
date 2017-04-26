package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalFactory
import graphmodel.internal._Point
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IMoveBendpointContext
import org.eclipse.graphiti.features.impl.DefaultMoveBendpointFeature
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection

class CincoMoveBendpointFeature extends DefaultMoveBendpointFeature {
	new(IFeatureProvider fp) {
		super(fp)
	}

	override boolean canMoveBendpoint(IMoveBendpointContext context) {
		return super.canMoveBendpoint(context)
	}

	override boolean moveBendpoint(IMoveBendpointContext context) {
		var boolean retval = super.moveBendpoint(context)
		var FreeFormConnection connection = context.getConnection()
		var InternalEdge edge = (getBusinessObjectForPictogramElement(connection) as InternalEdge)
		var _Point p = InternalFactory.eINSTANCE.create_Point() => [x = context.x; y = context.y]
		edge.getBendpoints().set(context.getBendpointIndex(), p)
		return retval
	}
}
