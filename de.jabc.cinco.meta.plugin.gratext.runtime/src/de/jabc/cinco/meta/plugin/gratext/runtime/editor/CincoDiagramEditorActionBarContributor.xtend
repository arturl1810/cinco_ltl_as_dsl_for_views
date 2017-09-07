package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.jface.action.Separator

class CincoDiagramEditorActionBarContributor extends DiagramEditorActionBarContributor {
	
	override buildActions() {
		System.err.println("[CDEABC] Build Actions")
		super.buildActions
		EdgeLayoutMode.values
			.map[createEdgeLayoutRetargetAction]
			.forEach[addRetargetAction]
	}
	
	override contributeToToolBar(IToolBarManager tbm) {
		System.err.println("[CDEABC] Contribute to Toolbar")
		super.contributeToToolBar(tbm)
		EdgeLayoutMode.values
			.map[getAction(id)]
			.forEach[tbm.add(it)]
		tbm.add(new Separator)
	}
	
	override dispose() {
		val bars = actionBars
		actionRegistry.actions.filter(IAction)
			.forEach[bars.setGlobalActionHandler(id, null)]
	}
}
