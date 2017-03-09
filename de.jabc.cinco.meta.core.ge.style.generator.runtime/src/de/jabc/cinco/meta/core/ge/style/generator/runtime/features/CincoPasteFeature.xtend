package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IPasteContext
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.features.AbstractPasteFeature
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalModelElement

class CincoPasteFeature extends AbstractPasteFeature{
	
	new(IFeatureProvider fp) {
		super(fp)
	}
	
	override canPaste(IPasteContext context) {
		true
	}
	
	override paste(IPasteContext context) {
		var copies = fromClipboard
		val target = context.pictogramElements.get(0) as ContainerShape
		copies.forEach[(it as PictogramElement).addToTarget(target)]
	}
	
	
	def void addToTarget(PictogramElement pe, ContainerShape cs) {
		cs.children.add(pe as Shape);
		var container = cs.link.businessObjects.get(0) as InternalModelElementContainer
		container.modelElements.addAll(pe.link.businessObjects.map[it as InternalModelElement])
	}
	
}