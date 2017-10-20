package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.editors.text.TextEditor
import org.eclipse.ui.editors.text.TextEditorActionContributor
import org.eclipse.ui.part.MultiPageEditorActionBarContributor

class ActionBarContributor extends MultiPageEditorActionBarContributor {
	
	IEditorPart activePage
	TextEditorActionContributor textEditorContributor

	new() { super() }

	def getTextEditorActionContributor(IEditorPart editor) {
		textEditorContributor ?: (textEditorContributor = new TextEditorActionContributor)
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
		switch it:editor {
			PageAwareEditor: actionBarContributor
			TextEditor: textEditorActionContributor
			default: return
		} => [
			init(actionBars, getPage)
			activeEditor = editor
		]
	}

	def deactivateActionContributor(IEditorPart page) {
		switch it:page {
			PageAwareEditor: disposeActionBarContributor
			TextEditor: textEditorContributor?.dispose
		}
	}

	def updateGlobalActionHandlers() {
		actionBars?.updateActionBars
	}
}
