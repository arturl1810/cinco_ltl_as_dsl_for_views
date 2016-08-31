package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.ui.IEditorPart;

public interface PageAwareness {

	void handlePageActivated(IEditorPart prevEditor);
	
	void handlePageDeactivated(IEditorPart nextEditor);
}
