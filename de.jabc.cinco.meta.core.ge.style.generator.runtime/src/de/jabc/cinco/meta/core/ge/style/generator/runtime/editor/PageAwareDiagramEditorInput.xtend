package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor

import java.util.function.Supplier
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.ui.editor.DiagramEditorInput
import de.jabc.cinco.meta.core.ui.editor.PageAwareEditorInput
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import org.eclipse.ui.IEditorInput

class PageAwareDiagramEditorInput extends DiagramEditorInput implements PageAwareEditorInput {
	
	Supplier<Resource> innerStateSupplier

	new (IEditorInput input) {
		this(new WorkbenchExtension().getURI(input))
	}

	new (URI diagramUri) {
		super(diagramUri, null)
	}

	override getInnerStateSupplier() {
		innerStateSupplier
	}

	override setInnerStateSupplier(Supplier<Resource> supplier) {
		innerStateSupplier = supplier
	}
}
