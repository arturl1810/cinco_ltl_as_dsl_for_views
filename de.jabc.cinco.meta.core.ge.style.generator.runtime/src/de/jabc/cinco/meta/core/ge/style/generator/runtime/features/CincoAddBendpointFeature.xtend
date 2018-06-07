package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalFactory
import graphmodel.internal._Point
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IAddBendpointContext
import org.eclipse.graphiti.features.impl.DefaultAddBendpointFeature

class CincoAddBendpointFeature extends DefaultAddBendpointFeature {
	new(IFeatureProvider fp) {
		super(fp) // TODO Auto-generated constructor stub
	}

	override boolean canAddBendpoint(IAddBendpointContext context) {
		return super.canAddBendpoint(context)
	}

	override void addBendpoint(IAddBendpointContext context) {
		var InternalEdge edge = (getBusinessObjectForPictogramElement(context.getConnection()) as InternalEdge)
		if (!edge.pointExists(context.x, context.y)) {
			super.addBendpoint(context)
			var _Point p = InternalFactory.eINSTANCE.create_Point() => [x = context.x; y = context.y]
			edge.getBendpoints().add(context.getBendpointIndex(), p)
//			println(edge.bendpoints)
		}
	}
	
	def pointExists(InternalEdge e, int x, int y) {
		e.bendpoints?.exists[it.x == x && it.y == y]
	}
}
