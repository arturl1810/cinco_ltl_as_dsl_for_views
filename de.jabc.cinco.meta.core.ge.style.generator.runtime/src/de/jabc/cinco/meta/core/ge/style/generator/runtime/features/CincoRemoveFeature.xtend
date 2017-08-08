package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.impl.DefaultRemoveFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IRemoveContext

class CincoRemoveFeature extends DefaultRemoveFeature {
	
	new(IFeatureProvider fp) {
		super(fp)
	}
	
	override canRemove(IRemoveContext context) {
		super.canRemove(context) && context.pictogramElement != null
	}
	
}