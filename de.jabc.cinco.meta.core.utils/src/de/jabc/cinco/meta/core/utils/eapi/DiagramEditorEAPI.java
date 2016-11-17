package de.jabc.cinco.meta.core.utils.eapi;

import graphmodel.GraphModel;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;

public class DiagramEditorEAPI {

	private DiagramEditor editor;
	
	public DiagramEditorEAPI(DiagramEditor editor) {
		this.editor = editor;
	}
	
	public Object getBusinessObject(PictogramElement pe) {
		IFeatureProvider fp = getFeatureProvider();
		return (fp != null) ? fp.getBusinessObjectForPictogramElement(pe) : null;
	}
		
	public Object getPictogramElement(Object businessObject) {
		IFeatureProvider fp = getFeatureProvider();
		return (fp != null) ? fp.getPictogramElementForBusinessObject(businessObject) : null;
	}

	public Diagram getDiagram() {
		IDiagramTypeProvider dtp = editor.getDiagramTypeProvider();
		return (dtp != null) ? dtp.getDiagram() : null;
	}
	
	public IFeatureProvider getFeatureProvider() {
		IDiagramTypeProvider dtp = editor.getDiagramTypeProvider();
		return (dtp != null) ? dtp.getFeatureProvider() : null;
	}
	
	public GraphModel getModel() {
		Object bo = getBusinessObject(getDiagram());
		return (bo != null && bo instanceof GraphModel) ? (GraphModel) bo : null;
	}
	
	public ResourceSet getResourceSet() {
		DiagramBehavior db = editor.getDiagramBehavior();
		return (db != null) ? db.getResourceSet() : null;
	}
}