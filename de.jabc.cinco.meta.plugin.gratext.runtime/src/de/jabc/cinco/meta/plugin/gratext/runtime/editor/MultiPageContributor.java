package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.gef.ui.actions.ActionRegistry;
import org.eclipse.jface.action.IAction;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.actions.ActionFactory;
import org.eclipse.ui.ide.IDEActionFactory;
import org.eclipse.ui.part.MultiPageEditorActionBarContributor;
import org.eclipse.ui.texteditor.ITextEditor;

public class MultiPageContributor extends MultiPageEditorActionBarContributor {

	private IEditorPart activeEditor;
	private IActionBars actionBars;
	private ActionRegistry actionRegistry;

	public MultiPageContributor() {
		super();
	}

	IAction getAction(String actionID) {
		if (activeEditor == null)
			return null;
		if (activeEditor instanceof ITextEditor)
			return ((ITextEditor) activeEditor).getAction(actionID);
		if (actionRegistry != null)
			return actionRegistry.getAction(actionID);
		return null;
	}
	
	void setGlobalActionHandlers(ActionFactory... actions) {
		for (ActionFactory action : actions)
			actionBars.setGlobalActionHandler(action.getId(), getAction(action.getId()));
	}
	
	void updateGlobalActionHandlers() {
		if (actionBars != null) {
			setGlobalActionHandlers(
					ActionFactory.DELETE,
					ActionFactory.UNDO,
					ActionFactory.REDO,
					ActionFactory.CUT,
					ActionFactory.COPY,
					ActionFactory.PASTE,
					ActionFactory.SELECT_ALL,
					ActionFactory.FIND,
					IDEActionFactory.BOOKMARK,
					IDEActionFactory.ADD_TASK
			);
			actionBars.updateActionBars();
		}
	}

	/*
	 * (non-JavaDoc) Method declared in MultiPageEditorActionBarContributor.
	 */
	public void setActivePage(IEditorPart editor) {
		if (activeEditor == editor) return;
		
		activeEditor = editor;
		actionRegistry = (ActionRegistry) editor.getAdapter(ActionRegistry.class);
		actionBars = getActionBars();
		
		updateGlobalActionHandlers();
	}
}
