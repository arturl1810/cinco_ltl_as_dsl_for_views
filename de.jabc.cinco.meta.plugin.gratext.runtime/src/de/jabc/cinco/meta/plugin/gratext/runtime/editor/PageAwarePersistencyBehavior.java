package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.emf.common.util.URI;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.ui.editor.DefaultPersistencyBehavior;

public class PageAwarePersistencyBehavior extends DefaultPersistencyBehavior {

	public PageAwarePersistencyBehavior(PageAwareDiagramBehavior diagramBehavior) {
		super(diagramBehavior);
	}
	
	protected PageAwareDiagramBehavior getDiagramBehavior() {
		return (PageAwareDiagramBehavior) diagramBehavior;
	}
	
	protected void flushCommandStack() {
		diagramBehavior.getEditingDomain().getCommandStack().flush();
		savedCommand = diagramBehavior.getEditingDomain().getCommandStack().getUndoCommand();
		diagramBehavior.getDiagramContainer().updateDirtyState();
	}
	
	protected Diagram getDiagram() {
		try {
			return (Diagram) getDiagramBehavior().getInnerState().getContents().get(0);
		} catch(NullPointerException | IndexOutOfBoundsException e) {
			return null;
		}
	}
	
	@Override
	public Diagram loadDiagram(URI uri) {
		Diagram diagram = getDiagram();
		if (diagram != null) {
			diagram.eResource().setTrackingModification(true);
			return diagram;
		}
		else return super.loadDiagram(uri);
	}
	
}
