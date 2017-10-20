package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor
import de.jabc.cinco.meta.core.ui.editor.PageAwareEditorDescriptor
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import java.util.Set
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.internal.registry.EditorDescriptor

class PageAwareEditorRegistry {
	
	public static final NonEmptyRegistry<String,Set<PageAwareEditorDescriptor>>
		INSTANCE = new NonEmptyRegistry[fileName | newHashSet => [
			for (desc : PlatformUI.workbench.editorRegistry.getEditors(fileName)) {
				if (desc instanceof EditorDescriptor) {
					val editor = desc.createEditor
					if (editor instanceof PageAwareEditor)
						add(new PageAwareEditorDescriptor(editor as PageAwareEditor))
				}
			}
		]
	]
}