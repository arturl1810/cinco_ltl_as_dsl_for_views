package de.jabc.cinco.meta.core.ge.style.generator.runtime.api;

import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public interface CModelElement {

	public <T extends PictogramElement> T getPictogramElement();
	
}
