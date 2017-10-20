package de.jabc.cinco.meta.core.ui.editor;

import org.eclipse.ui.IEditorPart;

public interface PageAwareness {

	void handlePageActivated(IEditorPart prevEditor);
	
	void handlePageDeactivated(IEditorPart nextEditor);
	
	void handleSaved();
}
