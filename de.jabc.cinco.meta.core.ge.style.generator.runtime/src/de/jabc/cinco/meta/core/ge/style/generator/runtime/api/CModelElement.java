package de.jabc.cinco.meta.core.ge.style.generator.runtime.api;

import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public interface CModelElement {

	public <T extends PictogramElement> T getPictogramElement();
	public <T extends PictogramElement> void setPictogramElement(T pe);
	
	public Diagram getDiagram();
	
	default void addLinksToDiagram(PictogramElement pe) {
		getDiagram().getPictogramLinks().add(pe.getLink());
		if (pe instanceof org.eclipse.graphiti.mm.pictograms.ContainerShape) {
			((org.eclipse.graphiti.mm.pictograms.ContainerShape) pe).getChildren().forEach(c -> addLinksToDiagram(c));
		}
		if (pe instanceof org.eclipse.graphiti.mm.pictograms.Connection) {
			((org.eclipse.graphiti.mm.pictograms.Connection) pe).getConnectionDecorators().forEach(cd -> addLinksToDiagram(cd));
		}
	}
}
