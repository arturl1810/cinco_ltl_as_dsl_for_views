package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.gef.ui.actions.ActionRegistry;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchActionConstants;
import org.eclipse.ui.actions.ActionFactory;
import org.eclipse.ui.ide.IDEActionFactory;
import org.eclipse.ui.part.MultiPageEditorActionBarContributor;
import org.eclipse.ui.texteditor.ITextEditor;
import org.eclipse.ui.texteditor.ITextEditorActionConstants;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.ui.editors.text.TextEditor;
import org.eclipse.ui.editors.text.TextEditorActionContributor;
import org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor;

public class MultiPageContributor extends MultiPageEditorActionBarContributor {

	private IEditorPart activeEditor;
//	private IActionBars actionBars;
	private ActionRegistry actionRegistry;
	
	private TextEditorActionContributor xtextEditorAC;
	private DiagramEditorActionBarContributor diagramEditorAC;

	public MultiPageContributor() {
		super();
	}

//	IAction getAction(String actionID) {
//		if (activeEditor == null)
//			return null;
//		if (activeEditor instanceof ITextEditor)
//			return ((ITextEditor) activeEditor).getAction(actionID);
//		if (actionRegistry != null)
//			return actionRegistry.getAction(actionID);
//		return null;
//	}
//	
//	void setGlobalActionHandlers(ActionFactory... actions) {
//		for (ActionFactory action : actions)
//			actionBars.setGlobalActionHandler(action.getId(), getAction(action.getId()));
//	}
	
	void updateGlobalActionHandlers() {
		//System.out.println("Update action handlers: " + getActionBars());
		if (getActionBars() != null) {
//			setGlobalActionHandlers(
//					ActionFactory.DELETE,
//					ActionFactory.UNDO,
//					ActionFactory.REDO,
//					ActionFactory.CUT,
//					ActionFactory.COPY,
//					ActionFactory.PASTE,
//					ActionFactory.SELECT_ALL,
//					ActionFactory.FIND,
//					IDEActionFactory.BOOKMARK,
//					IDEActionFactory.ADD_TASK
//			);
			getActionBars().updateActionBars();
		}
	}
	
	public void contributeToMenu(IMenuManager menu) {
		//System.out.println("Contribute to menu: " + menu);
		super.contributeToMenu(menu);

		IMenuManager editMenu= menu.findMenuUsingPath(IWorkbenchActionConstants.M_EDIT);
		if (editMenu != null) {
//			editMenu.appendToGroup(ITextEditorActionConstants.GROUP_ASSIST, fQuickAssistMenuEntry);
//			fQuickAssistMenuEntry.setVisible(false);
//			editMenu.appendToGroup(ITextEditorActionConstants.GROUP_INFORMATION, fRetargetShowInformationAction);
		}
	}

	/*
	 * (non-JavaDoc) Method declared in MultiPageEditorActionBarContributor.
	 */
	public void setActivePage(IEditorPart page) {
		//System.out.println("Set active page: " + page);
		if (activeEditor == page) return;
		
		activeEditor = page;
		actionRegistry = (ActionRegistry) page.getAdapter(ActionRegistry.class);
//		actionBars = getActionBars();
		
		if (page instanceof TextEditor) {
			activateTextEditorActionContributor(page);
		} else {
			deactivateTextEditorActionContributor(page);
		}
		
		if (page instanceof DiagramEditor) {
			activateDiagramEditorActionContributor(page);
		} else {
			deactivateDiagramEditorActionContributor(page);
		}
		
		updateGlobalActionHandlers();
	}
	
	void activateTextEditorActionContributor(IEditorPart editor) {
		//System.out.println("Activate TextEditorActionContributor");
		if (xtextEditorAC == null) {
			xtextEditorAC = new TextEditorActionContributor();
			xtextEditorAC.init(getActionBars(), getPage());
		}
		xtextEditorAC.setActiveEditor(editor);
	}
	
	void deactivateTextEditorActionContributor(IEditorPart editor) {
		//System.out.println("Dispose TextEditorActionContributor");
		if (xtextEditorAC != null) {
			xtextEditorAC.dispose();
		}
	}
	
	void activateDiagramEditorActionContributor(IEditorPart editor) {
		//System.out.println("Activate DiagramEditorActionContributor");
		if (diagramEditorAC == null) {
			diagramEditorAC = new DiagramEditorActionBarContributor();
			diagramEditorAC.init(getActionBars(), getPage());
		}
		diagramEditorAC.setActiveEditor(editor);
	}
	
	void deactivateDiagramEditorActionContributor(IEditorPart editor) {
		//System.out.println("Dispose DiagramEditorActionContributor");
		if (diagramEditorAC != null) {
			diagramEditorAC.dispose();
		}
	}
	
	@Override
	public void setActiveEditor(IEditorPart part) {
		//System.out.println("Set active editor: " + part);
		super.setActiveEditor(part);
	}
}
