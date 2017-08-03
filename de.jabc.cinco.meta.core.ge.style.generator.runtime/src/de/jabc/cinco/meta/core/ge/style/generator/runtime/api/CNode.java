package de.jabc.cinco.meta.core.ge.style.generator.runtime.api;

import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.AnchorContainer;
import org.eclipse.graphiti.mm.pictograms.ChopboxAnchor;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory;

import graphmodel.ModelElement;

public interface CNode extends CModelElement {

	public default Anchor getAnchor() {
		PictogramElement pe = getPictogramElement();
		if (pe instanceof AnchorContainer) {
			AnchorContainer ac = ((AnchorContainer) pe);
			if (((AnchorContainer) pe).getAnchors().isEmpty()) {
				ChopboxAnchor anchor = PictogramsFactory.eINSTANCE.createChopboxAnchor();
				anchor.setActive(false);
				anchor.setParent(ac);
			}
			return ((AnchorContainer) pe).getAnchors().get(0);
		} else throw new RuntimeException(String.format("Could not retrieve anchors from PictogramElement %s", pe));
	};
}
