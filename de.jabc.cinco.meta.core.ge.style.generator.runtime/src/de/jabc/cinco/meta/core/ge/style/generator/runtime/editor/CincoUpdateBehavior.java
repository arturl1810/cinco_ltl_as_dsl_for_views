package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.core.commands.operations.DefaultOperationHistory;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.edit.provider.ComposedAdapterFactory;
import org.eclipse.emf.transaction.impl.TransactionalEditingDomainImpl;
import org.eclipse.emf.workspace.WorkspaceEditingDomainFactory;
import org.eclipse.emf.workspace.util.WorkspaceSynchronizer;
import org.eclipse.graphiti.ui.editor.DefaultUpdateBehavior;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.graphiti.ui.internal.editor.GFWorkspaceCommandStackImpl;

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditorInput;

@SuppressWarnings("restriction")
public class CincoUpdateBehavior extends DefaultUpdateBehavior {

	private boolean isMultiPageContext;
	
	public CincoUpdateBehavior(PageAwareDiagramBehavior diagramBehavior) {
		super(diagramBehavior);
	}
	
	@Override
	public void createEditingDomain(IDiagramEditorInput input) {
		Resource innerState = getInnerState(input);
		if (innerState != null) {
			TransactionalEditingDomainImpl domain = new TransactionalEditingDomainImpl(
					new ComposedAdapterFactory(ComposedAdapterFactory.Descriptor.Registry.INSTANCE),
					new GFWorkspaceCommandStackImpl(new DefaultOperationHistory()),
					innerState.getResourceSet());
			WorkspaceEditingDomainFactory.INSTANCE.mapResourceSet(domain);
			initializeEditingDomain(domain);
		} else {
			super.createEditingDomain(input);
		}
	}
	
	@Override
	protected WorkspaceSynchronizer.Delegate createWorkspaceSynchronizerDelegate() {
		if (isMultiPageContext) {
			// workspace sync should be managed by the multi-page editor
			return null;
		}
		else return super.createWorkspaceSynchronizerDelegate();
	}
	
	private Resource getInnerState(IDiagramEditorInput input) {
		isMultiPageContext = input instanceof PageAwareEditorInput;
		return isMultiPageContext
			? ((PageAwareEditorInput) input).getInnerStateSupplier().get()
			: null;
	}
}
