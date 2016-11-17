package de.jabc.cinco.meta.core.utils.eapi;

import graphmodel.GraphModel;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;

public class DiagramTypeProviderEAPI {

	private IDiagramTypeProvider dtp;
	
	public DiagramTypeProviderEAPI(IDiagramTypeProvider editor) {
		this.dtp = editor;
	}
	
	public Object getBusinessObject(PictogramElement pe) {
		IFeatureProvider fp = dtp.getFeatureProvider();
		return (fp != null) ? fp.getBusinessObjectForPictogramElement(pe) : null;
	}
	
	public GraphModel getModel() {
		Object bo = getBusinessObject(dtp.getDiagram());
		return (bo != null && bo instanceof GraphModel) ? (GraphModel) bo : null;
	}
	
	public ResourceSet getResourceSet() {
		Object db = dtp.getDiagramBehavior();
		return (db != null && db instanceof DiagramBehavior) ? ((DiagramBehavior)db).getResourceSet() : null;
	}
}