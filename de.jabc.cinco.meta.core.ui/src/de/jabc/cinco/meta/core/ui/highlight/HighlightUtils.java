package de.jabc.cinco.meta.core.ui.highlight;


import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;

import de.jabc.cinco.meta.runtime.xapi.DiagramExtension;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;

import graphmodel.ModelElement;

/**
 * Utility methods for handling highlight-related stuff.
 * 
 * @author Steve Bosselmann
 */
public class HighlightUtils {
	
	private static DiagramExtension diagramX = new DiagramExtension();
	private static ResourceExtension resourceX = new ResourceExtension();
	private static WorkbenchExtension workbenchX = new WorkbenchExtension();
	
	public static DiagramBehavior getDiagramBehavior() {
		return workbenchX.getDiagramBehavior(workbenchX.getActiveDiagram());
	}
	
	public static ArrayList<ContainerShape> getContainerShapes() {
		return diagramX.getContainerShapes(workbenchX.getActiveDiagram());
	}
	
	public static List<Shape> getShapes() {
		return diagramX.getShapes(workbenchX.getActiveDiagram());
	}

	public static Object getBusinessObject(PictogramElement pe) {
		return workbenchX.getBusinessObject(pe);
	}
	
	public static boolean testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		return workbenchX.testBusinessObjectType(pe, cls);
	}
	
	public static void refreshDiagram() {
		workbenchX.refresh(workbenchX.getActiveDiagram());
	}
	
	public static void refreshDecorators() {
		refreshDecorators(getShapes());
	}

	public static void refreshDecorators(ModelElement element) {
		Diagram diagram = resourceX.getDiagram(element.eResource());
		refreshDecorators(diagramX.getShapes(diagram));
	}
	
	public static void refreshDecorators(Collection<? extends PictogramElement> pes) {
		pes.stream().forEach(pe ->
			getDiagramBehavior().refreshRenderingDecorators(pe));
		getDiagramBehavior().refresh();
	}
	
	public static void refreshDecorators(PictogramElement pe) {
		getDiagramBehavior().refreshRenderingDecorators(pe);
		getDiagramBehavior().refresh();
	}
}
