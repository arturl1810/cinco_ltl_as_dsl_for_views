package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.editor.DefaultRefreshBehavior;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.parts.IAnchorContainerEditPart;

@SuppressWarnings("restriction")
public class CincoRefreshBehavior extends DefaultRefreshBehavior {

	public CincoRefreshBehavior(DiagramBehavior diagramBehavior) {
		super(diagramBehavior);
	}

//	@Override
//	public void refreshRenderingDecorators(PictogramElement pe) {
//		super.refreshRenderingDecorators(pe);
//	}
//	
//	public void refreshRenderingDecorators(Iterable<PictogramElement> pe) {
//		GraphicalEditPart ep = diagramBehavior.getEditPartForPictogramElement(pe);
//		if (ep instanceof IAnchorContainerEditPart) {
//			IAnchorContainerEditPart acep = (IAnchorContainerEditPart) ep;
//			acep.refreshDecorators();
//		}
//	}
}
