package de.jabc.cinco.meta.plugin.gratext.template

class PageAwareDiagramEditorTemplate extends AbstractGratextTemplate {
		
override template()
'''
package «project.basePackage»;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;

import «model.basePackage».editor.graphiti.«model.name»DiagramEditor;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareDiagramBehavior;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareEditorPart;

public class PageAware«model.name»DiagramEditor extends «model.name»DiagramEditor implements PageAwareEditorPart {
	
	PageAwareDiagramBehavior diagramBehavior;
	
	@Override
	protected PageAwareDiagramBehavior createDiagramBehavior() {
		diagramBehavior = (PageAwareDiagramBehavior) super.createDiagramBehavior();
		return diagramBehavior;
	}
	
	public Resource getInnerState() {
		return diagramBehavior.getInnerState();
	}
	
	public void handlePageActivated(IEditorPart prevEditor) {
		diagramBehavior.handlePageActivated(prevEditor);
	}

	@Override
	public void handlePageDeactivated(IEditorPart nextEditor) {
		diagramBehavior.handlePageDeactivated(nextEditor);
	}
	
	@Override
	public void handleInnerStateChanged() {
		diagramBehavior.handleInnerStateChanged();
	}

	@Override
	public void handleNewInnerState() {
		IEditorInput input = getEditorInput();
		if (input instanceof IDiagramEditorInput) {
			diagramBehavior.getUpdateBehavior().createEditingDomain((IDiagramEditorInput) input);
		}
	}

	@Override
	public void handleSaved() {
		diagramBehavior.handleSaved();
	}
}
'''
}