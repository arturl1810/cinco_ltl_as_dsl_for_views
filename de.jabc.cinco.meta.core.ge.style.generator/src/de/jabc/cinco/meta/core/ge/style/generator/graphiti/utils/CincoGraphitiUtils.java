package de.jabc.cinco.meta.core.ge.style.generator.graphiti.utils;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.platform.IDiagramBehavior;
import org.eclipse.graphiti.ui.platform.AbstractImageProvider;
import org.eclipse.graphiti.ui.platform.IImageProvider;
import org.eclipse.graphiti.ui.services.GraphitiUi;

/**
 * @author Dawid Kopetzki
 * 
 * An utility class for some Graphiti-related tasks 
 *
 */
public class CincoGraphitiUtils {

	private IImageProvider cincoImageProvider;

	public static IDiagramBehavior getDiagramBehavior(PictogramElement pe) {
		EObject current = pe;
		if (current == null) 
			return null;
		while (!(current instanceof Diagram))
			current = current.eContainer();
		if (current instanceof Diagram)
			return getDiagramBehavior((Diagram) current);
		else throw new RuntimeException("Could not find Diagram for PictogramElement: " + pe);
	}
	
	public static IDiagramBehavior getDiagramBehavior(Diagram d) {
		String diagramTypeId = d.getDiagramTypeId();
		String diagramTypeProviderId = GraphitiUi.getExtensionManager().getDiagramTypeProviderId(diagramTypeId);
		IDiagramTypeProvider dtp = GraphitiUi.getExtensionManager().createDiagramTypeProvider(d, diagramTypeProviderId);
		return dtp.getDiagramBehavior();
	}
	
	/**
	 * @param diagram The diagram for which the DiagramTypeProvider should be created
	 * @return DiagramTypeProvider for the given ID and Diagram
	 */
	public static IDiagramTypeProvider getDTP(Diagram diagram) {
		String diagramTypeId = diagram.getDiagramTypeId();
		String dtpID = GraphitiUi.getExtensionManager().getDiagramTypeProviderId(diagramTypeId);
		return GraphitiUi.getExtensionManager().createDiagramTypeProvider(diagram, dtpID);
	}
	
	/** Returns a diagram type provider without the need of a opened diagram editor.
	 * 
	 * @param dtpID ID of the DiagramTypeProvider
	 * @return A new instance of a diagram type provider with the specified id.
	 */
	public static IDiagramTypeProvider getDTP(String dtpID) {
		return GraphitiUi.getExtensionManager().createDiagramTypeProvider(dtpID);
	}
	
	public static AbstractImageProvider getIP() {
		return null;
	}
}
