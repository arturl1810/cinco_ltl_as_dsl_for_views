package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.function.Supplier;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.graphiti.ui.editor.DiagramEditorInput;

public class PageAwareDiagramEditorInput extends DiagramEditorInput implements PageAwareEditorInput {
	
	private Supplier<Resource> innerStateSupplier;

	public PageAwareDiagramEditorInput(URI diagramUri) {
		super(diagramUri, null);
	}

	@Override
	public Supplier<Resource> getInnerStateSupplier() {
		return innerStateSupplier;
	}

	@Override
	public void setInnerStateSupplier(Supplier<Resource> supplier) {
		innerStateSupplier = supplier;
	}
}
