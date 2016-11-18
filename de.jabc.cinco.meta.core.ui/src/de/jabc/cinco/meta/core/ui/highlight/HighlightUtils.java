package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;
import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.getDiagramBehavior;
import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.getShapes;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;
import graphmodel.ModelElement;

import java.util.Collection;

import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

/**
 * Utility methods for handling highlight-related stuff.
 * 
 * @author Steve Bosselmann
 */
public class HighlightUtils {
	
	public static void refreshDecorators() {
		refreshDecorators(getShapes());
	}

	public static void refreshDecorators(ModelElement element) {
		Diagram diagram = eapi(element.eResource()).getDiagram();
		refreshDecorators(eapi(diagram).getShapes());
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
