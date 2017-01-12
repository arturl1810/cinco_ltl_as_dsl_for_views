package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.getDiagramBehavior;
import static de.jabc.cinco.meta.core.utils.eapi.Cinco.eapi;

import java.util.Collection;

import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import de.jabc.cinco.meta.core.utils.eapi.Cinco.Workbench;
import graphmodel.ModelElement;

/**
 * Utility methods for handling highlight-related stuff.
 * 
 * @author Steve Bosselmann
 */
public class HighlightUtils {
	
	public static void refreshDecorators() {
		refreshDecorators(Workbench.getShapes());
	}

	public static void refreshDecorators(ModelElement element) {
		Diagram diagram = eapi(element.eResource()).getDiagram();
		refreshDecorators(eapi(diagram).getShapes());
	}
	
	public static void refreshDecorators(Collection<? extends PictogramElement> pes) {
		pes.stream().forEach(pe ->
		Workbench.getDiagramBehavior().refreshRenderingDecorators(pe));
		getDiagramBehavior().refresh();
	}
	
	public static void refreshDecorators(PictogramElement pe) {
		getDiagramBehavior().refreshRenderingDecorators(pe);
		getDiagramBehavior().refresh();
		
	}
}
