package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor;
import de.jabc.cinco.meta.core.utils.registry.KeygenRegistry;

public class MultiPageEditorContributorRegistry {

	public static KeygenRegistry<Class<? extends PageAwareEditor>, MultiPageEditorContributor>
		INSTANCE = new KeygenRegistry<>((MultiPageEditorContributor c) -> c.getEditorClass());

}
