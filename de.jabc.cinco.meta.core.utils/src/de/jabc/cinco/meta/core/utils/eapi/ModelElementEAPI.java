package de.jabc.cinco.meta.core.utils.eapi;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;

import graphmodel.ModelElement;

import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.WorkbenchUtil;

public class ModelElementEAPI {

	private ModelElement element;
	
	public ModelElementEAPI(ModelElement element) {
		this.element = element;
	}
	

//	public boolean canBeCreated() {
//		
//		getPictogramElement().getLink().eContainer()
//		WorkbenchUtil.getDiagramTypeProvider().getFeatureProvider().getMoveShapeFeature(context);
//		
//		return !CincoUtils.isCreateDisabled(element);
//	}
	

	public PictogramElement getPictogramElement() {
		Diagram diagram = eapi(element.eResource()).getDiagram();
		return eapi(diagram).getPictogramElement(element);
	}
}