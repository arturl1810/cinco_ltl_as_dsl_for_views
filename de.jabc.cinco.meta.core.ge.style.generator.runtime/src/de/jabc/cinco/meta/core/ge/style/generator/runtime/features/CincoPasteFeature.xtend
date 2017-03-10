package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IPasteContext
import org.eclipse.graphiti.mm.pictograms.Connection
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
		switch (pe) {
			Shape : { 
				cs.children.add(pe as Shape);
				var container = cs.link.businessObjects.get(0) as InternalModelElementContainer 
				val ime = pe.link.businessObjects.get(0) as InternalModelElement
				container.modelElements.add(ime)
			}
			Connection : {
				diagram.connections.add(pe)
				var graphmodel = diagram.link.businessObjects.get(0) as InternalGraphModel
				var edge = pe.link.businessObjects.get(0) as InternalEdge
				val commonContainer = getCommonContainer(graphmodel, edge)
				commonContainer.modelElements.add(edge)
			}
		}
		
		pe.addPictogramLinks
	}
	
	def void addPictogramLinks(PictogramElement pe) {
		if (!diagram.pictogramLinks.contains(pe.link))
			diagram.pictogramLinks.add(pe.link)
		if (pe instanceof ContainerShape)
			pe.children.forEach[addPictogramLinks]
	}
	
	def moveBy(PictogramElement pe, int x, int y) {
		var newX = pe.graphicsAlgorithm.x + x
		var newY = pe.graphicsAlgorithm.y + y
		Graphiti.gaService.setLocation(pe.graphicsAlgorithm, newX, newY)
	}
	
	def InternalModelElementContainer getCommonContainer(InternalModelElementContainer ce, InternalEdge e) {
		var source = e.get_sourceElement();
		var target = e.get_targetElement();
		if (org.eclipse.emf.ecore.util.EcoreUtil.isAncestor(ce, source) && org.eclipse.emf.ecore.util.EcoreUtil.isAncestor(ce, target)) {
			for (InternalContainer c : ce.modelElements.filter[it instanceof InternalContainer].map[it as InternalContainer]) {
				if (org.eclipse.emf.ecore.util.EcoreUtil.isAncestor(c, source) && org.eclipse.emf.ecore.util.EcoreUtil.isAncestor(c, target)) {
					return getCommonContainer(c, e);
				}
			}
		} else if (ce instanceof InternalModelElement) {
			getCommonContainer(ce.getContainer(), e);
		}
		ce
	}
	
}