package de.jabc.cinco.meta.core.ui.highlight;

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;
import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.edit;
import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.getDiagramBehavior;
import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.getShapes;

import graphmodel.ModelElement;

import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import java.util.Collection;

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
		pes.stream().forEach(pe -> refreshDecorators(pe));
	}
	
	public static void refreshDecorators(PictogramElement pe) {
		getDiagramBehavior().refreshRenderingDecorators(pe);
	}
	
	public static void triggerUpdate(PictogramElement pe) {
		GraphicsAlgorithm ga = pe.getGraphicsAlgorithm();
		edit(pe).apply(() -> {
			if (pe instanceof Connection) {
				ga.setLineVisible(!ga.getLineVisible());
				ga.setLineVisible(!ga.getLineVisible());
			} else {
				ga.setFilled(!ga.getFilled());
				ga.setFilled(!ga.getFilled());
			}
		});
	}
}
