package de.jabc.cinco.meta.runtime.xapi

import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.internal.InternalIdentifiableElement
import java.util.function.Predicate
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.part.MultiPageEditorPart

import static org.eclipse.emf.ecore.util.EcoreUtil.equals
import graphmodel.ModelElement
import graphmodel.internal.InternalModelElement

/**
 * Workbench-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkbenchExtension extends de.jabc.cinco.meta.util.xapi.WorkbenchExtension {
	
	/**
	 * Retrieves the diagram that currently is edited in the active editor
	 * in the active workbench window.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return the active diagram, or {@code null} if it cannot be retrieved
	 *   for whatever reason.
	 */
	def getActiveDiagram() {
		activeDiagramEditor?.diagram
	}
	
	/**
	 * Retrieves the graph model that currently is edited in the active editor
	 * in the active workbench window.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return the active graph model, or {@code null} if it cannot be retrieved
	 *   for whatever reason.
	 */
	def getActiveGraphModel() {
		activeEditor?.graphModel
	}
	
	/**
	 * Retrieves the active editor in the active page of the active workbench window,
	 * iff it is a diagram editor.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return the active diagram editor, or {@code null} if the active editor 
	 *   cannot be retrieved for whatever reason or it is not a diagram editor.
	 * @see #getActiveEditor()
	 */
	def DiagramEditor getActiveDiagramEditor() {
		activeEditor?.getDiagramEditor
	}
	
	/**
	 * Retrieves the active editor in the active page of the active workbench window,
	 * iff it is a diagram editor and it fulfills the specified predicate.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @param predicate to be tested against the diagram editor.
	 * @return the active diagram editor, or {@code null} if the active editor 
	 *   cannot be retrieved for whatever reason or it is not a diagram editor
	 *   or it does not fulfill the specified predicate.
	 * @see #getActiveEditor()
	 */
	def getDiagramEditor(Predicate<DiagramEditor> predicate) {
		activePage?.editorReferences
			?.map[getEditor(true)?.diagramEditor]
			?.filterNull
			?.findFirst[predicate.test(it)]
	}
	
	/**
	 * Retrieves the diagram editor from the specified editor. This is either
	 * the specified editor itself or if the selected page of the specified
	 * editor if it is a multi-page editor and the selected page is a diagram
	 * editor.
	 * 
	 * @param editor to retrieve the diagram editor from.
	 * @return the active diagram editor, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def DiagramEditor getDiagramEditor(IEditorPart editor) {
		switch editor {
			MultiPageEditorPart: 
				switch it:editor.selectedPage {
					DiagramEditor: it
				}
			DiagramEditor: editor
		}
	}
	
	/**
	 * Retrieves the diagram editor of the specified diagram.
	 * 
	 * @param diagram to retrieve the editor for.
	 * @return the diagram editor, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def DiagramEditor getEditor(Diagram diagram) {
		getDiagramEditor[editor | editor.diagram == diagram]
	}
	
	/**
	 * Retrieves the diagram editor of the specified pictogram element.
	 * 
	 * @param pictogramElement to retrieve the editor for.
	 * @return the diagram editor, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getEditor(PictogramElement pictogramElement) {
		getDiagramEditor[resource == pictogramElement.eResource]
	}
	
	/**
	 * Retrieves the diagram editor of the specified model element.
	 * 
	 * @param modelElement to retrieve the editor for.
	 * @return the diagram editor, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getEditor(IdentifiableElement modelElement) {
		getDiagramEditor[resource == modelElement.eResource]
	}
	
	/**
	 * Retrieves the diagram of the specified pictogram element.
	 * 
	 * @param pictogramElement to retrieve the diagram for.
	 * @return the diagram, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getDiagram(PictogramElement pictogramElement) {
		try {
			EcoreUtil.getRootContainer(pictogramElement) as Diagram
		} catch(Exception e) {
			null
		}
	}
	
	/**
	 * Retrieves the diagram of the specified model element.
	 * 
	 * @param modelElement to retrieve the diagram for.
	 * @return the diagram, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getDiagram(IdentifiableElement modelElement) {
		extension val ext = new ResourceExtension
		modelElement.eResource?.diagram
	}
	
	/**
	 * Retrieves the {@link DiagramBehavior} of the specified diagram.
	 * 
	 * @param diagram to retrieve the {@link DiagramBehavior} for.
	 * @return the {@link DiagramBehavior}, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getDiagramBehavior(Diagram diagram) {
		diagram.editor?.diagramBehavior
	}
	
	/**
	 * Retrieves the {@link DiagramBehavior} of the diagram of the specified
	 * pictogram element.
	 * 
	 * @param pictogramElement to retrieve the {@link DiagramBehavior} for.
	 * @return the {@link DiagramBehavior}, or {@code null} if it cannot be
	 *   retrieved for whatever reason.
	 */
	def getDiagramBehavior(PictogramElement pictogramElement) {
		pictogramElement.editor?.diagramBehavior
	}
	
	/**
	 * Retrieves the {@link DiagramTypeProvider} of the specified
	 * diagram editor.
	 * 
	 * @param editor to retrieve the {@link DiagramTypeProvider} for.
	 * @return the {@link DiagramTypeProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getDiagramTypeProvider(DiagramEditor editor) {
		editor?.diagramTypeProvider
	}
	
	/**
	 * Retrieves the {@link DiagramTypeProvider} of the specified diagram.
	 * 
	 * @param diagram to retrieve the {@link DiagramTypeProvider} for.
	 * @return the {@link DiagramTypeProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getDiagramTypeProvider(Diagram diagram) {
		diagram.editor?.diagramTypeProvider
	}
	
	/**
	 * Retrieves the {@link DiagramTypeProvider} of the specified pictogram
	 * element.
	 * 
	 * @param pictogramElement to retrieve the {@link DiagramTypeProvider} for.
	 * @return the {@link DiagramTypeProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getDiagramTypeProvider(PictogramElement pictogramElement) {
		pictogramElement.diagram?.diagramTypeProvider
	}
	
	/**
	 * Retrieves the {@link FeatureProvider} of the specified diagram editor.
	 * 
	 * @param editor to retrieve the {@link FeatureProvider} for.
	 * @return the {@link FeatureProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getFeatureProvider(DiagramEditor editor) {
		editor.diagramTypeProvider?.featureProvider
	}
	
	/**
	 * Retrieves the {@link FeatureProvider} of the specified diagram.
	 * 
	 * @param diagram to retrieve the {@link FeatureProvider} for.
	 * @return the {@link FeatureProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getFeatureProvider(Diagram diagram) {
		diagram.diagramTypeProvider?.featureProvider
	}
	
	/**
	 * Retrieves the {@link FeatureProvider} of the specified pictogram element.
	 * 
	 * @param pictogramElement to retrieve the {@link FeatureProvider} for.
	 * @return the {@link FeatureProvider}, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getFeatureProvider(PictogramElement pictogramElement) {
		pictogramElement.diagramTypeProvider?.featureProvider
	}
	
	/**
	 * Retrieves the business object linked to the specified pictogram element.
	 * 
	 * @param pictogramElement to retrieve the business object for.
	 * @return the business object, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getBusinessObject(PictogramElement pictogramElement) {
		pictogramElement.featureProvider?.getBusinessObjectForPictogramElement(pictogramElement)
		?: Graphiti.linkService.getBusinessObjectForLinkedPictogramElement(pictogramElement)
	}
	
	/**
	 * Retrieves the pictogram element linked to the specified element.
	 * 
	 * @param element to retrieve the pictogram element for.
	 * @return the pictogram element, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def getPictogramElement(IdentifiableElement element) {
		extension val ResourceExtension = new ResourceExtension
		element.internalElement.eResource?.diagram?.pictogramLinks
			?.filter[businessObjects.exists[equals(it, element)]]
			?.map[pictogramElement]
			?.findFirst[it !== null]
	}
	
	/**
	 * Retrieves the pictogram element linked to the specified element.
	 * 
	 * @param element to retrieve the pictogram element for.
	 * @return the pictogram element, or {@code null} if it cannot
	 *   be retrieved for whatever reason.
	 */
	def testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		val bo = pe.businessObject
		if (bo === null)
			return false
		var test = cls.isAssignableFrom(bo.class)
		if (!test && bo instanceof InternalIdentifiableElement) {
			test = cls.isAssignableFrom((bo as InternalIdentifiableElement).element.class)
		}
		return test
	}
	
	/**
	 * Retrieves the diagram that is currently edited in the specified editor.
	 */
	def getDiagram(DiagramEditor editor) {
		editor.diagramTypeProvider?.diagram
	}
	
	/**
	 * Retrieves the diagram contained in the underlying resource that represents
	 * this editor's input.
	 * It is assumed that the editor implements the interface
	 * {@code IEditingDomainProvider}.
	 * It is assumed that a diagram exists and is placed at the default location
	 * (i.e. the first content object of the resource).
	 * However, if the content object at this index is not a diagram all content
	 * objects are searched through for diagrams and the first occurrence is
	 * returned, if existent.
	 * 
	 * Convenience method for {@code getContent(Diagram.class, 0)}.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any diagram.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def getDiagram(IEditorPart editor) {
		extension val ext = new ResourceExtension
		editor?.resource?.diagram
	}
	
	/**
	 * Retrieves all model elements that are currently selected in the editor.
	 * Returns an empty list if the diagram does not exist or the editor is closed.
	 */
	def getSelectedModelElements(GraphModel model) {
		model?.diagram?.selectedPictogramElements
			.map[businessObject]
			.filter(InternalModelElement)
			.map[element]
	}
	
	/**
	 * Retrieves all pictogram elements that are currently selected in the editor.
	 * Returns an empty list if the diagram does not exist or the editor is closed.
	 */
	def getSelectedPictogramElements(Diagram diagram) {
		diagram?.diagramBehavior?.selectedPictogramElements?.toList ?: #[]
	}
	
	/**
	 * Tests whether the specified model element is currently selected in the editor.
	 */
	def isSelected(ModelElement element) {
		element?.rootElement?.selectedModelElements?.exists[it == element]
	}
	
	/**
	 * Tests whether the specified model element is currently selected in the editor.
	 */
	def isSelected(PictogramElement element) {
		element?.diagram?.selectedPictogramElements?.contains(element)
	}
	
	/**
	 * Selects the specified model element by replacing the current selection.
	 * 
	 */
	def void select(ModelElement element) {
		element.diagram?.select(#[element.pictogramElement])
	}
	
	/**
	 * Selects the specified pictogram element by replacing the current selection.
	 */
	def void select(PictogramElement pe) {
		pe.diagram?.select(#[pe])
	}
	
	/**
	 * Selects the specified model elements by replacing the current selection.
	 */
	def void select(GraphModel model, ModelElement[] elements) {
		model.diagram?.select(elements?.map[pictogramElement])
	}
	
	/**
	 * Selects the specified pictogram elements by replacing the current selection.
	 */
	def void select(Diagram diagram, PictogramElement[] pes) {
		diagram.diagramBehavior?.diagramContainer?.selectPictogramElements(pes)
	}
	
	/**
	 * Unselects the specified model element.
	 */
	def void unselect(ModelElement element) {
		element.pictogramElement?.unselect
	}
	
	/**
	 * Unselects the specified pictogram element.
	 */
	def void unselect(PictogramElement pe) {
		pe.diagram?.unselect(#[pe])
	}
	
	/**
	 * Unselects the specified model elements.
	 */
	def void unselect(GraphModel model, ModelElement[] elements) {
		model.diagram?.unselect(elements?.map[pictogramElement])
	}
	
	/**
	 * Unselects the specified pictogram elements.
	 */
	def void unselect(Diagram it, PictogramElement[] pes) {
		select(selectedPictogramElements.filter[!pes.contains(it)])
	}
	
	/**
	 * Clears the current selection.
	 */
	def void clearSelection(GraphModel model) {
		model.diagram?.clearSelection
	}
	
	/**
	 * Clears the current selection.
	 */
	def void clearSelection(Diagram diagram) {
		diagram.select(#[])
	}
	
	/**
	 * Retrieves the graph model contained in the underlying resource that
	 * represents this editor's input.
	 * It is assumed that the editor implements the interface
	 * {@code IEditingDomainProvider}.
	 * It is assumed that a graph model exists and is placed at the default location
	 * (i.e. the second content object of the resource).
	 * However, if the content object at this index is not a graph model all content
	 * objects are searched through for graph models and the first occurrence is
	 * returned, if existent.
	 * 
	 * Convenience method for {@code getContent(GraphModel.class, 1)}.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any graph model.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def getGraphModel(IEditorPart editor) {
		extension val ext = new ResourceExtension
		editor.resource?.graphModel
	}
	
	/**
	 * Retrieves the graph model of the specified type contained in the underlying
	 * resource that represents this editor's input.
	 * It is assumed that the editor implements the interface
	 * {@code IEditingDomainProvider}.
	 * It is assumed that a graph model of the specified type exists and is placed
	 * at the default location (i.e. the second content object of the resource).
	 * However, if the content object at this index is not a graph model of the
	 * specified type all content objects are searched through for graph models
	 * of that type and the first occurrence is returned, if existent.
	 * 
	 * Convenience method for {@code getContent(<ModelClass>, 1)}.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any graph
	 *   model of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends GraphModel> T getGraphModel(IEditorPart editor, Class<T> modelClass) {
		extension val ext = new ResourceExtension
		editor?.resource?.getContent(modelClass, 1)
	}
	
	def getLinkedGraphModel(Diagram diagram) {
		diagram.businessObject
	}
	
	def refresh(Diagram diagram) {
		async[ diagram.diagramBehavior?.refreshContent ]
	}
	
	def refreshDiagramEditor() {
		async[ activeDiagramEditor?.diagramBehavior?.refresh ]
	}
	
	def refreshDecorators(PictogramElement pe) {
		async[ pe.editor?.diagramBehavior?.refreshRenderingDecorators(pe) ]
	}
	
	def refreshDecorators(Iterable<PictogramElement> pes) {
		val db = pes?.map[editor?.diagramBehavior]?.filterNull?.head
		if (db !== null) 
			async[ for (pe : pes) db.refreshRenderingDecorators(pe) ] 
		else System.err.println("No DiagramBehavior found for any pictogram")
	}
	
	def int showCustomQuestionDialog(String title, String message, String[] buttonLabels) {
		new MessageDialog(display.activeShell, title,
            null, message, MessageDialog.QUESTION,
            buttonLabels, 0).open
	}
	
	def boolean showConfirmDialog(String title, String message) {
		MessageDialog.openConfirm(
				display.activeShell, title, message)
	}
	
	def void showErrorDialog(String title, String message) {
		MessageDialog.openError(
				display.activeShell, title, message)
	}
	
	def void showInfoDialog(String title, String message) {
		MessageDialog.openInformation(
				display.activeShell, title, message)
	}
	
	def boolean showQuestionDialog(String title, String message) {
		MessageDialog.openQuestion(
				display.activeShell, title, message)
	}
	
	def void showWarningDialog(String title, String message) {
		MessageDialog.openWarning(
				display.activeShell, title, message)
	}
	
	/**
	 * Retrieves the underlying file for the specified EObject and opens
	 * it in a new editor in the active page of the active workbench window.
	 * @return 
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized 
	 */
	def IEditorPart openEditor(EObject obj) {
		extension val we = new WorkspaceExtension
		extension val fe = new FileExtension
		obj.getFile?.openInEditor as IEditorPart
	}
}
