package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.function.Supplier;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.ui.IEditorInput;

public interface PageAwareEditorInput extends IEditorInput {

	Supplier<Resource> getInnerStateSupplier();
	
	void setInnerStateSupplier(Supplier<Resource> supplier);
}
