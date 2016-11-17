package de.jabc.cinco.meta.core.utils.eapi;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;

import graphmodel.ModelElement;

import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

public class ModelElementEAPI {

	private ModelElement element;
	
	public ModelElementEAPI(ModelElement element) {
		this.element = element;
	}
	
	public PictogramElement getPictogramElement() {
		Diagram diagram = eapi(element.eResource()).getDiagram();
		return eapi(diagram).getPictogramElement(element);
	}
}