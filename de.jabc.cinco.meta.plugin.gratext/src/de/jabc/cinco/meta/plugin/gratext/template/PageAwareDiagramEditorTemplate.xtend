package de.jabc.cinco.meta.plugin.gratext.template

class PageAwareDiagramEditorTemplate extends AbstractGratextTemplate {
		
override template()
'''
package «project.basePackage»;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.ui.IEditorInput;

import «model.basePackage».graphiti.«model.name»DiagramEditor;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareDiagramBehavior;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareEditorPart;

public class PageAware«model.name»DiagramEditor extends «model.name»DiagramEditor implements PageAwareEditorPart {
	
	PageAwareDiagramBehavior diagramBehavior;
	
	@Override
	protected PageAwareDiagramBehavior createDiagramBehavior() {
		diagramBehavior = new PageAwareDiagramBehavior(this);
		return diagramBehavior;
	}
	
	public Resource getInnerState() {
		return diagramBehavior.getInnerState();
	}
	
	public void handlePageActivated() {
		diagramBehavior.handlePageActivated();
	}

	@Override
	public void handlePageDeactivated() {
		diagramBehavior.handlePageDeactivated();
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
}
'''
}