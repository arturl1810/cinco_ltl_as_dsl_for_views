package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor
import de.jabc.cinco.meta.core.utils.registry.Registry
import org.eclipse.ui.IEditorActionBarContributor
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.editors.text.TextEditor
import org.eclipse.ui.editors.text.TextEditorActionContributor
import org.eclipse.ui.part.EditorActionBarContributor
import org.eclipse.ui.part.MultiPageEditorActionBarContributor

class ActionBarContributor extends MultiPageEditorActionBarContributor {
	
	IEditorPart activePage
	val contributors = new Registry<Class<? extends IEditorPart>,IEditorActionBarContributor>

	new() { super() }

	def getActionContributor(IEditorPart editor) {
		contributors.get(editor.class)
		?: switch it:editor {
			PageAwareEditor: actionBarContributor
			TextEditor: new TextEditorActionContributor
		} => [
			if (it != null) contributors.put(editor.class, it)
		]
	}

	override setActivePage(IEditorPart page) {
		if (activePage === page)
			return;
		activePage?.deactivateActionContributor
		activePage = page
		activePage?.activateActionContributor
		updateGlobalActionHandlers
	}

	def activateActionContributor(IEditorPart editor) {
		editor.actionContributor => [
			if (it instanceof EditorActionBarContributor) {
				if (it.page == null) {
					init(this.actionBars, this.getPage)
				}
			} else if (it != null) {
				System.err.println("["+this.class.simpleName + "] "
					+ "WARN Unknown type of action bar contributor: " + it.class)
				init(this.actionBars, this.getPage)
			}
			if (it != null) {
				activeEditor = editor
			}
		]
	}

	def deactivateActionContributor(IEditorPart editor) {
		contributors.get(editor.class)?.dispose
	}

	def updateGlobalActionHandlers() {
		actionBars?.updateActionBars
	}
}
