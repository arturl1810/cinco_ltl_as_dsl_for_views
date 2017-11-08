package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalGraphModel
import java.util.HashSet
import java.util.Set
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICopyContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.features.AbstractCopyFeature

class CincoCopyFeature extends AbstractCopyFeature {
	
	extension CincoGraphitiCopier = new CincoGraphitiCopier
	
	new(IFeatureProvider fp) {
		super(fp)
	}

	override boolean canCopy(ICopyContext context) {
		!(context.pictogramElements.get(0).businessObjectForPictogramElement instanceof InternalGraphModel)
	}

	override void copy(ICopyContext context) {
		var pes = new HashSet<PictogramElement>()
		pes.addAll(context.getPictogramElements.toList)
		pes.computeUpperLeft
		var connections = pes.edges
		pes.addAll(connections)
		var Object[] objects = newArrayOfSize(pes.length)
		var result = pes.map[(it as PictogramElement).copyPE]
		for (i : 0..<pes.length) {
			objects.set(i, result.get(i))
		}
		putToClipboard(objects)
	}

	private def edges(Set<PictogramElement> pes) {
		val allpes = pes.map[allContainedPes].flatten
		allpes.dropWhile[it instanceof Connection]
		allpes.map[ pe |
			if (pe instanceof AnchorContainer) {
				pe.anchors?.map[connection(allpes)]
			}
		].flatten.flatten.clone
	}
	
	private def connection(Anchor a, Iterable<PictogramElement> pes) {
		val connections  = (a?.incomingConnections + a?.outgoingConnections)
		connections.filter[pes.toSet.contains(start.parent) && pes.toSet.contains(end.parent)].toSet
	}
	
	private def Iterable<PictogramElement> allContainedPes(PictogramElement pe) {
		if (pe instanceof ContainerShape) {
			#[pe] + pe.children.map[allContainedPes].flatten
		}
		else #[pe]

	}
}
