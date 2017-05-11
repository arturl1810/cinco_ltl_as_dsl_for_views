package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor;
import org.eclipse.jface.action.IAction;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.editors.text.TextEditor;
import org.eclipse.ui.editors.text.TextEditorActionContributor;
import org.eclipse.ui.part.MultiPageEditorActionBarContributor;

public class MultiPageContributor extends MultiPageEditorActionBarContributor {

	private IEditorPart activeEditor;
	private TextEditorActionContributor xtextEditorAC;
	private DiagramEditorActionBarContributor diagramEditorAC;

	public MultiPageContributor() {
		super();
	}
	
	void updateGlobalActionHandlers() {
		if (getActionBars() != null) {
			getActionBars().updateActionBars();
		}
	}

	@Override
	public void setActivePage(IEditorPart page) {
		if (activeEditor == page)
			return;
		activeEditor = page;
		
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
		if (xtextEditorAC == null) {
			xtextEditorAC = new TextEditorActionContributor();
			xtextEditorAC.init(getActionBars(), getPage());
		}
		xtextEditorAC.setActiveEditor(editor);
	}
	
	void deactivateTextEditorActionContributor(IEditorPart editor) {
		if (xtextEditorAC != null) {
			xtextEditorAC.dispose();
		}
	}
	
	void activateDiagramEditorActionContributor(IEditorPart editor) {
		if (diagramEditorAC == null) {
			diagramEditorAC = new DiagramEditorActionBarContributor() {
				@SuppressWarnings("unchecked")
				@Override public void dispose() {
					IActionBars bars = getActionBars();
					getActionRegistry().getActions().forEachRemaining((action) -> {
						String id = ((IAction) action).getId();
						bars.setGlobalActionHandler(id, null);
					});
				}
			};
			diagramEditorAC.init(getActionBars(), getPage());
		}
		diagramEditorAC.setActiveEditor(editor);
	}
	
	void deactivateDiagramEditorActionContributor(IEditorPart editor) {
		if (diagramEditorAC != null) {
			diagramEditorAC.dispose();
		}
	}
}
