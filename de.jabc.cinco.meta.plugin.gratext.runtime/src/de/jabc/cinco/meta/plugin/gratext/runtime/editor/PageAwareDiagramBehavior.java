package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;

public class PageAwareDiagramBehavior extends DiagramBehavior implements InnerStateAwareness, PageAwareness {
	
	public PageAwareDiagramBehavior(DiagramEditor editor) {
		super(editor);
	}

	@Override
	protected PageAwarePersistencyBehavior createPersistencyBehavior() {
		return new PageAwarePersistencyBehavior(this);
	}
	
	@Override
	protected PageAwareUpdateBehavior createUpdateBehavior() {
		return new PageAwareUpdateBehavior(this);
	}
	
	@Override
	protected PageAwarePersistencyBehavior getPersistencyBehavior() {
		return (PageAwarePersistencyBehavior) super.getPersistencyBehavior();
	}
	
	@Override
	public PageAwareUpdateBehavior getUpdateBehavior() {
		return (PageAwareUpdateBehavior) super.getUpdateBehavior();
	}
	
	@Override
	public Resource getInnerState() {
		IDiagramEditorInput input = getInput();
		if (input instanceof PageAwareEditorInput)
			return ((PageAwareEditorInput) getInput()).getInnerStateSupplier().get();
		else
			return null;
	}
	
	@Override
	public void handlePageActivated() {
		getUpdateBehavior().setResourceChanged(false);
		refreshContent();
	}

	@Override
	public void handleInnerStateChanged() {
		refreshContent();
		getUpdateBehavior().setResourceChanged(false);
		getPersistencyBehavior().clearDirtyState();
	}
	
	@Override
	public void handlePageDeactivated() {
		/* do nothing */
	}
	
	@Override
	public void handleNewInnerState() {
		/* do nothing */
	}
}
