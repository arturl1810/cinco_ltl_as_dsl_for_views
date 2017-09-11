package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.actions.GEFActionConstants
import org.eclipse.graphiti.ui.editor.DiagramEditorContextMenuProvider
import org.eclipse.graphiti.ui.platform.IConfigurationProvider
import org.eclipse.jface.action.IMenuManager
import org.eclipse.jface.action.MenuManager

import static de.jabc.cinco.meta.plugin.gratext.runtime.editor.EdgeLayout.*

class CincoDiagramEditorContextMenuProvider extends DiagramEditorContextMenuProvider {
	
	ActionRegistry actionRegistry
	
	new(EditPartViewer viewer, ActionRegistry registry, IConfigurationProvider configurationProvider) {
		super(viewer, registry, configurationProvider)
		this.actionRegistry = registry
	}
	
	override protected addDefaultMenuGroupRest(IMenuManager manager) {
		manager.addLayoutSubMenu(GEFActionConstants.GROUP_REST)
		super.addDefaultMenuGroupRest(manager)
	}
	
	def addLayoutSubMenu(IMenuManager manager, String group) {
		val menu = new MenuManager("Layout");
		
		// add edge layout actions
		#[ C_LEFT,C_TOP,C_RIGHT,C_BOTTOM,
		   Z_HORIZONTAL,Z_VERTICAL,
		   TO_LEFT,TO_TOP,TO_RIGHT,TO_BOTTOM
		].map[id].forEach[id|
			val action = actionRegistry.getAction(id)
			if (action?.isEnabled)
				menu.add(action)
		]
		
		if (!menu.isEmpty())
			manager.appendToGroup(group, menu)
	}
}