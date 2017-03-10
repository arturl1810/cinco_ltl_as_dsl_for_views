package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IPasteContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.features.AbstractPasteFeature

class CincoPasteFeature extends AbstractPasteFeature{
	
	extension CincoGraphitiCopier = new CincoGraphitiCopier
	
	new(IFeatureProvider fp) {
		super(fp)
	}
	
	override canPaste(IPasteContext context) {
		true
	}
	
	override paste(IPasteContext context) {
		var copies = copiesFromClipBoard.map[it as PictogramElement]
		copies = copies.map[copyPE]
		copies.forEach[moveBy(100,100)]
		val target = context.pictogramElements.get(0) as ContainerShape
		copies.forEach[(it as PictogramElement).addToTarget(target)]
	}
	
	
	def void addToTarget(PictogramElement pe, ContainerShape cs) {
		cs.children.add(pe as Shape);
		var container = cs.link.businessObjects.get(0) as InternalModelElementContainer 
		container.modelElements.add(pe.link.businessObjects.get(0) as InternalModelElement)
		diagram.pictogramLinks.add(pe.link)
	}
	
	def moveBy(PictogramElement pe, int x, int y) {
		var newX = pe.graphicsAlgorithm.x + x
		var newY = pe.graphicsAlgorithm.y + y
		Graphiti.gaService.setLocation(pe.graphicsAlgorithm, newX, newY)
	}
	
}