package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICopyContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.features.AbstractCopyFeature

class CincoCopyFeature extends AbstractCopyFeature {
	
	extension CincoGraphitiCopier = new CincoGraphitiCopier
	
	new(IFeatureProvider fp) {
		super(fp)
	}

	override void copy(ICopyContext context) {
		var PictogramElement[] pes = context.getPictogramElements
		var Object[] objects = newArrayOfSize(pes.length)
		var result = pes.map[(it as PictogramElement).copyPE]
		for (i : 0..<pes.length) {
			objects.set(i, result.get(i))
		}
		println(result)
		putToClipboard(objects)
	}

	override boolean canCopy(ICopyContext context) {
		true
	}
	
}
