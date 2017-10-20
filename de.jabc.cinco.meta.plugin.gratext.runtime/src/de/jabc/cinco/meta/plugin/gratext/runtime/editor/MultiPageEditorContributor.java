package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor;

public interface MultiPageEditorContributor {

	public Class<? extends PageAwareEditor> getEditorClass();
	
}
