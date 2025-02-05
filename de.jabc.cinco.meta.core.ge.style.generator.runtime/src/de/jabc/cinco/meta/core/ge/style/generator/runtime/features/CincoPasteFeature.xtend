package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.Edge
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Node
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import java.util.List
import org.eclipse.emf.common.util.BasicEList
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
		var objects = fromClipboard
		
		if (objects.exists[it instanceof PictogramElement === false])
			return false
			
		var pes = context.pictogramElements
		
		if (objects.nullOrEmpty || pes.nullOrEmpty)
			return false
		
		var InternalModelElementContainer target
		if (getBusinessObjectForPictogramElement(pes.head) instanceof InternalModelElementContainer)
			target = getBusinessObjectForPictogramElement(pes.head) as InternalModelElementContainer
		else return false
		
 		var nodes = objects.map[(it as PictogramElement).link.businessObjects.head].filter(typeof(Node))
		target.canContainNodes(new BasicEList(nodes.toList))
	}
	
	override paste(IPasteContext context) {
		var copies = fromClipboard.map[it as PictogramElement]
		copies = copies.map[copyPE]
		copies.translate(context)
		copies.setCModelElementPictogram
		val target = context.pictogramElements.get(0) as ContainerShape
		copies.filter(typeof(Shape)).forEach[(it as PictogramElement).addToTarget(target)]
		copies.filter(typeof(Connection)).forEach[(it as PictogramElement).addToTarget(target)]
	}
	
	def void addToTarget(PictogramElement pe, ContainerShape cs) {
		switch (pe) {
			Shape : { 
				cs.children.add(pe as Shape);
				var bo = cs.link.businessObjects.get(0)
				var InternalModelElementContainer container
				if (bo instanceof ModelElementContainer)
					container = bo.internalContainerElement
				if (bo instanceof InternalModelElementContainer)
					container = bo 
				val ime = (pe.link.businessObjects.get(0) as ModelElement).internalElement
				container.modelElements.add(ime)
			}
			Connection : {
				diagram.connections.add(pe)
				var graphmodel = diagram.link.businessObjects.get(0) as InternalGraphModel
				var edge = (pe.link.businessObjects.get(0) as Edge).internalElement as InternalEdge
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
		
//		println("context x : " + context.x + "/ context y : " + context.y)
//		println("abs min x : " + minXabs + "/ abs min y : " + minYabs)
		pes.forEach[ pe | 
			switch (pe) {
				Shape: {
					pe.graphicsAlgorithm.x = context.x - target.containerShift.x + (pe.graphicsAlgorithm.x - minX)
					pe.graphicsAlgorithm.y = context.y - target.containerShift.y + (pe.graphicsAlgorithm.y - minY)
					var bo = pe.link.businessObjects.head as Node
					var internalNode = bo.internalElement as InternalNode
					internalNode.x = pe.graphicsAlgorithm.x
					internalNode.y = pe.graphicsAlgorithm.y					
				}
				FreeFormConnection: {
//					pe.bendpoints.forEach[bp |
//						println("bendpoint before: " + bp.x + "/" + bp.y)
//						bp.x = context.x + (bp.x - minX)
//						bp.y = context.y + (bp.y - minY)
//						println("bendpoint after: " + bp.x + "/" + bp.y)
//					]
					for (p : pe.bendpoints) {
//						println("Bendpoint at:\t" + p.x + "/" + p.y)
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
	
	private def void setCModelElementPictogram(List<PictogramElement> pes) {
		for (pe : pes){ 
			var bo = pe.link.businessObjects.head
			if (bo instanceof ModelElement) {
				var element = bo
				if (element instanceof CModelElement)
					if (element.pictogramElement == null)
						element.pictogramElement = pe
			}
			if (pe instanceof ContainerShape)
				setCModelElementPictogram(pe.children.map[it as PictogramElement])
		}
	}
}