package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor

import de.jabc.cinco.meta.core.ge.style.generator.runtime.layout.EdgeLayout
import org.eclipse.gef.editparts.ZoomManager
import org.eclipse.gef.ui.actions.ZoomComboContributionItem
import org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.jface.action.Separator
import org.eclipse.ui.IEditorPart

import static de.jabc.cinco.meta.core.ge.style.generator.runtime.layout.EdgeLayout.*

class CincoDiagramEditorActionBarContributor extends DiagramEditorActionBarContributor {
	
	ZoomComboContributionItem zoomCombo
	ZoomManager zoomManager
	
	override buildActions() {
		super.buildActions
		EdgeLayout.values
			.map[createRetargetAction]
			.forEach[addRetargetAction]
	}
	
	override contributeToToolBar(IToolBarManager tbm) {
		super.contributeToToolBar(tbm)
		
		// add edge layout actions
		#[C_LEFT,C_TOP,C_RIGHT,C_BOTTOM]
			.map[getAction(id)]
			.forEach[tbm.add(it)]
		tbm.add(new Separator)
		#[Z_HORIZONTAL,Z_VERTICAL]
			.map[getAction(id)]
			.forEach[tbm.add(it)]
		tbm.add(new Separator)
		#[TO_LEFT,TO_TOP,TO_RIGHT,TO_BOTTOM]
			.map[getAction(id)]
			.forEach[tbm.add(it)]
		tbm.add(new Separator)
		
		zoomCombo = tbm.items.filter(ZoomComboContributionItem).head
	}
	
	override dispose() {
		val bars = actionBars
		actionRegistry.actions.filter(IAction)
			.forEach[bars.setGlobalActionHandler(id, null)]
			
		zoomManager = zoomCombo?.zoomManager
		zoomCombo?.setZoomManager(null)
	}
	
	override setActiveEditor(IEditorPart editor) {
		super.setActiveEditor(editor)
		zoomCombo?.setZoomManager(zoomManager)
	}
	
}
