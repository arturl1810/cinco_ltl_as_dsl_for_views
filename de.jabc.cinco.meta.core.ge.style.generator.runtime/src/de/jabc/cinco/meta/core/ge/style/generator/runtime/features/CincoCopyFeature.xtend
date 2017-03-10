package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICopyContext
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.AnchorContainer
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.features.AbstractCopyFeature
import org.eclipse.graphiti.mm.pictograms.Connection
import java.util.ArrayList
import java.util.HashSet

class CincoCopyFeature extends AbstractCopyFeature {
	
	extension CincoGraphitiCopier = new CincoGraphitiCopier
	
	new(IFeatureProvider fp) {
		super(fp)
	}

	override boolean canCopy(ICopyContext context) {
		true
	}

	override void copy(ICopyContext context) {
		var pes = new HashSet<PictogramElement>()
		pes.addAll(context.getPictogramElements.toList)
		var connections = pes.edges
		connections.forEach[println(it)]
		pes.addAll(connections)
		var Object[] objects = newArrayOfSize(pes.length)
		var result = pes.map[(it as PictogramElement).copyPE]
		for (i : 0..<pes.length) {
			objects.set(i, result.get(i))
		}
		println(result)
		putToClipboard(objects)
	}

	private def edges(PictogramElement[] pes) {
		pes.map[ pe |
			if (pe instanceof AnchorContainer) {
				pe.anchors.map[connection(pes)]
			}
		].flatten.flatten
	}
	
	private def connection(Anchor a, PictogramElement[] pes) {
		val connections  = (a.incomingConnections + a.outgoingConnections)
		connections.filter[pes.contains(start.parent) && pes.contains(end.parent)].toSet
	}
}
