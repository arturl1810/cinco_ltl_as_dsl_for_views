package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IRemoveBendpointContext
import org.eclipse.graphiti.features.impl.DefaultRemoveBendpointFeature
import graphmodel.internal.InternalEdge

class CincoRemoveBendpointFeature extends DefaultRemoveBendpointFeature {
	new(IFeatureProvider fp) {
		super(fp)
	}

	override boolean canRemoveBendpoint(IRemoveBendpointContext context) {
		return super.canRemoveBendpoint(context)
	}

	override void removeBendpoint(IRemoveBendpointContext context) {
		super.removeBendpoint(context)
		var InternalEdge edge = (getBusinessObjectForPictogramElement(context.getConnection()) as InternalEdge)
		edge.getBendpoints().remove(context.getBendpointIndex())
	}
}
