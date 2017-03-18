package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import java.util.List
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.IPasteContext
import org.eclipse.graphiti.mm.algorithms.styles.StylesFactory
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.features.AbstractPasteFeature

class CincoPasteFeature extends AbstractPasteFeature{
	
	extension CincoGraphitiCopier = new CincoGraphitiCopier
	extension GraphModelExtension = new GraphModelExtension
	
	new(IFeatureProvider fp) {
		super(fp)
	}
	
	override canPaste(IPasteContext context) {
		true
	}
	
	override paste(IPasteContext context) {
		var copies = copiesFromClipBoard.map[it as PictogramElement]
		copies = copies.map[copyPE]
		copies.translate(context)
		val target = context.pictogramElements.get(0) as ContainerShape
		copies.filter(typeof(Shape)).forEach[(it as PictogramElement).addToTarget(target)]
		copies.filter(typeof(Connection)).forEach[(it as PictogramElement).addToTarget(target)]
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
	
	def translate(List<PictogramElement> pes, IPasteContext context) {
		val target = context.pictogramElements.get(0)
		
		println("context x : " + context.x + "/ context y : " + context.y)
		println("abs min x : " + minXabs + "/ abs min y : " + minYabs)
		pes.forEach[ pe | 
			switch (pe) {
				Shape: {
					pe.graphicsAlgorithm.x = context.x - target.containerShift.x + (pe.graphicsAlgorithm.x - minX)
					pe.graphicsAlgorithm.y = context.y - target.containerShift.y + (pe.graphicsAlgorithm.y - minY)
				}
				FreeFormConnection: {
//					pe.bendpoints.forEach[bp |
//						println("bendpoint before: " + bp.x + "/" + bp.y)
//						bp.x = context.x + (bp.x - minX)
//						bp.y = context.y + (bp.y - minY)
//						println("bendpoint after: " + bp.x + "/" + bp.y)
//					]
					for (p : pe.bendpoints) {
						println("Bendpoint at:\t" + p.x + "/" + p.y)
						p.x = context.x + (p.x - minXabs)
						p.y = context.y + (p.y - minYabs)
					}
				}
			}
		]
	}
	
	
	private def containerShift(PictogramElement pe) {
		var current = pe
		var p = StylesFactory.eINSTANCE.createPoint => [x=0; y=0]
		while (current instanceof Shape && !(current instanceof Diagram)) {
			p.x = p.x + current.graphicsAlgorithm.x
			p.y = p.y + current.graphicsAlgorithm.y
			current = current.eContainer as PictogramElement
		}
		p
	}
}