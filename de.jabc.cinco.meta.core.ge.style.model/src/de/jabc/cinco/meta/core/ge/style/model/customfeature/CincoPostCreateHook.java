package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.mm.pictograms.Diagram;

abstract public class CincoPostCreateHook <T extends EObject> {

	private Diagram diagram;
	
	abstract public void postCreate(T object);
	
	public void postCreate(T object, Diagram d) {
		this.diagram = d;
		postCreate(object);
	}

	public Diagram getDiagram() {
		return diagram;
	}

	public void setDiagram(Diagram diagram) {
		this.diagram = diagram;
	}
	
	
}
