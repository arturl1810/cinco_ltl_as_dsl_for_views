package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.gef.editparts.ZoomManager;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.graphiti.ui.platform.IConfigurationProvider;
import org.eclipse.ui.IEditorPart;

public class PageAwareDiagramBehavior extends DiagramBehavior implements InnerStateAwareness, PageAwareness {
	
	public PageAwareDiagramBehavior(DiagramEditor editor) {
		super(editor);
	}
	
	@Override
	protected void initActionRegistry(ZoomManager zoomManager) {
		super.initActionRegistry(zoomManager);
//		for (EdgeLayoutMode value : EdgeLayoutMode.values()) {
//			registerAction(value.createEdgeLayoutAction(getParentPart()));
//		}
		registerAction(EdgeLayoutMode.C_TOP.createEdgeLayoutAction(getParentPart()));
	}
	
	protected IConfigurationProvider createConfigurationProvider(IDiagramTypeProvider diagramTypeProvider) {
		return new CincoConfigurationProvider(this, diagramTypeProvider);
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
	public void handlePageActivated(IEditorPart prevEditor) {
		getUpdateBehavior().setResourceChanged(false);
		refreshContent();
	}

	@Override
	public void handleInnerStateChanged() {
		refreshContent();
		getUpdateBehavior().setResourceChanged(false);
		getPersistencyBehavior().flushCommandStack();
	}
	
	@Override
	public void handlePageDeactivated(IEditorPart nextEditor) {
		/* do nothing */
	}
	
	@Override
	public void handleNewInnerState() {
		/* do nothing */
	}

	@Override
	public void handleSaved() {
		getUpdateBehavior().setResourceChanged(false);
		getPersistencyBehavior().clearDirtyState();
	}
}
