package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.IUpdateFeature;
import org.eclipse.graphiti.features.context.impl.UpdateContext;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.services.GraphitiUi;

abstract public class CincoPostCreateHook <T extends EObject> {

	private Diagram diagram;
	
	abstract public void postCreate(T object);
	
	public void postCreateAndUpdate(T object, Diagram d) {
		this.diagram = d;
		postCreate(object);
		update(object);
	}
	
	private void update(T object) {
		List<PictogramElement> linkedPictogramElements = Graphiti.getLinkService().getPictogramElements(getDiagram(), object);
		// if the element got deleted in the postCreateHook, linked elements will be empty
		if (linkedPictogramElements.isEmpty()) {
			return; 
		}
		UpdateContext uc = new UpdateContext(
				(PictogramElement) linkedPictogramElements.get(0));
		IFeatureProvider provider = GraphitiUi.getExtensionManager().createFeatureProvider(getDiagram());
		IUpdateFeature uf = provider.getUpdateFeature(uc);
		if (uf != null && uf.canUpdate(uc))
			uf.update(uc);
	}

	public Diagram getDiagram() {
		return diagram;
	}

	public void setDiagram(Diagram diagram) {
		this.diagram = diagram;
	}
	
	
}
