package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor
import de.jabc.cinco.meta.core.ui.editor.ResourceContributor
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.internal.InternalGraphModel
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.gef.dnd.TemplateTransferDragSourceListener
import org.eclipse.gef.ui.palette.PaletteViewer
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.IEditorPart
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.core.ge.style.generator.runtime.api.CModelElement
import org.eclipse.core.runtime.IConfigurationElement

abstract class CincoDiagramEditor extends DiagramEditor implements PageAwareEditor, ResourceContributor {
	
	protected extension ResourceExtension = new ResourceExtension
	protected extension WorkbenchExtension = new WorkbenchExtension
	
	CincoDiagramEditorActionBarContributor actionBarContributor
	PageAwareDiagramBehavior diagramBehavior
	
	def LazyDiagram createDiagram()
	
	override PageAwareDiagramBehavior createDiagramBehavior() {
		diagramBehavior = new PageAwareDiagramBehavior(this)
	}
	
	def onPaletteViewerCreated(PaletteViewer pViewer) {
		pViewer.addDragSourceListener(new TemplateTransferDragSourceListener(pViewer))
	}
	
	def PaletteViewer getPaletteViewer() {
		(paletteViewerProvider as CincoPaletteViewerProvider).paletteViewer
	}
	
	override getPageName() {
		"Diagram"
	}
	
	override mapEditorInput(IEditorInput input) {
		new PageAwareDiagramEditorInput(input.URI);
	}
	
	override getActionBarContributor() {
		actionBarContributor
		?: (actionBarContributor = new CincoDiagramEditorActionBarContributor)
	}
	
	override Resource getInnerState() {
		diagramBehavior.innerState
	}
	
	override handlePageActivated(IEditorPart prevEditor) {
		diagramBehavior.handlePageActivated(prevEditor);
	}

	override handlePageDeactivated(IEditorPart nextEditor) {
		diagramBehavior.handlePageDeactivated(nextEditor);
	}
	
	override handleInnerStateChanged() {
		diagramBehavior.handleInnerStateChanged();
		switch it:diagramTypeProvider.diagram {
			LazyDiagram: setDiagramBehavior(diagramBehavior)
		}
	}

	override handleNewInnerState() {
		switch input:editorInput {
			IDiagramEditorInput: diagramBehavior.updateBehavior.createEditingDomain(input)
		}
	}

	override handleSaved() {
		diagramBehavior.handleSaved();
	}
	
	override getResourceContributor() {
		this
	}
	
	override isResolveCrossReferencesRequired(EObject obj) {
		false
	}
	
	override contributeToResource(Resource resource) {
		val model = resource.getContent(InternalGraphModel)?.element
		if (model !== null) {
			val diagram = new DiagramBuilder(createDiagram, model).build(resource)
			if (model instanceof CModelElement)
				model.pictogramElement = diagram
		#[diagram] 
		}
		else #[]
	}
}