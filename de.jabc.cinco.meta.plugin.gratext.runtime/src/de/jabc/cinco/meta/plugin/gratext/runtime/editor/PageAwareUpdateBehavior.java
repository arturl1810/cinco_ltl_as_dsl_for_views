package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.core.commands.operations.DefaultOperationHistory;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.edit.provider.ComposedAdapterFactory;
import org.eclipse.emf.transaction.impl.TransactionalEditingDomainImpl;
import org.eclipse.emf.workspace.WorkspaceEditingDomainFactory;
import org.eclipse.graphiti.ui.editor.DefaultUpdateBehavior;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.graphiti.ui.internal.editor.GFWorkspaceCommandStackImpl;

public class PageAwareUpdateBehavior extends DefaultUpdateBehavior {

	public PageAwareUpdateBehavior(PageAwareDiagramBehavior diagramBehavior) {
		super(diagramBehavior);
	}
	
	@SuppressWarnings("restriction")
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
	
	private Resource getInnerState(IDiagramEditorInput input) {
		return input instanceof PageAwareEditorInput
			? ((PageAwareEditorInput) input).getInnerStateSupplier().get()
			: null;
	}
}
