package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor
import org.eclipse.jface.action.IAction
import static de.jabc.cinco.meta.plugin.gratext.runtime.editor.EdgeLayoutMode.*
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.jface.action.Separator

class CincoDiagramEditorActionBarContributor extends DiagramEditorActionBarContributor {
	
	override buildActions() {
		System.err.println("[CDEABC] Build Actions")
		super.buildActions
		addRetargetAction(EdgeLayoutRetargetAction.create(C_LEFT));
		addRetargetAction(EdgeLayoutRetargetAction.create(C_TOP));
	}
	
	override contributeToToolBar(IToolBarManager tbm) {
		System.err.println("[CDEABC] Contribute to Toolbar")
		super.contributeToToolBar(tbm)
		tbm.add(getAction(C_LEFT.id))
		tbm.add(new Separator)
	}
	
	override dispose() {
		val bars = actionBars
		actionRegistry.actions.filter(IAction)
			.forEach[bars.setGlobalActionHandler(id, null)]
	}
}
