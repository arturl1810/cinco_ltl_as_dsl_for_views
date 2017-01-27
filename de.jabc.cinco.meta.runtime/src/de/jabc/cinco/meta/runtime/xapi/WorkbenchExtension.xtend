package de.jabc.cinco.meta.runtime.xapi

import static org.eclipse.emf.ecore.util.EcoreUtil.equals

import de.jabc.cinco.meta.util.xapi.WorkspaceExtension
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import java.util.function.Predicate
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.domain.IEditingDomainProvider
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.part.MultiPageEditorPart

/**
 * Workbench-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkbenchExtension extends de.jabc.cinco.meta.util.xapi.WorkbenchExtension {
	
	def DiagramEditor getActiveDiagramEditor() {
		activeEditor?.getDiagramEditor
	}
	
	def getActiveDiagram() {
		val ae = activeEditor
		ae?.diagram
	}
	
	def getActiveDiagramEditor(Predicate<IEditorPart> predicate) {
		getActiveEditor(predicate).getDiagramEditor
	}
	
	def DiagramEditor getDiagramEditor(IEditorPart editor) {
		switch editor {
			MultiPageEditorPart: switch editor.selectedPage {
				DiagramEditor: editor.selectedPage as DiagramEditor
			}
			DiagramEditor: editor
		}
	}
	
	def DiagramEditor getEditor(Diagram diagram) {
		getActiveEditor[resource == diagram.eResource].getDiagramEditor
	}
	
	/**
	 * Retrieves the editor the pictogram is currently edited in, if existent.
	 */
	def getEditor(PictogramElement pe) {
		getActiveDiagramEditor[resource == pe.eResource]
	}
	
	/**
	 * Retrieves the editor the model element is currently edited in, if existent.
	 */
	def getEditor(IdentifiableElement modelElement) {
		getActiveDiagramEditor[resource == modelElement.eResource]
	}
	
	def getDiagram(IdentifiableElement element) {
		extension val ext = new ResourceExtension
		element.eResource?.diagram
	}
	
	def getDiagramBehavior(Diagram diagram) {
		diagram.editor?.diagramBehavior
	}
	
	def getDiagramBehavior(PictogramElement pe) {
		pe.editor?.diagramBehavior
	}
	
	def getDiagramTypeProvider(DiagramEditor editor) {
		editor?.diagramTypeProvider
	}
	
	def getDiagramTypeProvider(Diagram diagram) {
		diagram.editor?.diagramTypeProvider
	}
	
	def getDiagramTypeProvider(PictogramElement pe) {
		pe.editor?.diagramTypeProvider
	}
	
	def getFeatureProvider(DiagramEditor editor) {
		editor.diagramTypeProvider?.featureProvider
	}
	
	def getFeatureProvider(Diagram diagram) {
		diagram.diagramTypeProvider?.featureProvider
	}
	
	def getFeatureProvider(PictogramElement pe) {
		pe.diagramTypeProvider?.featureProvider
	}
	
	def getBusinessObject(DiagramEditor editor, PictogramElement pe) {
		editor.featureProvider?.getBusinessObjectForPictogramElement(pe)
	}
	
	def getBusinessObject(PictogramElement pe) {
		pe.editor?.getBusinessObject(pe)
	}
	
	def getPictogramElement(DiagramEditor editor, Object businessObject) {
		editor.featureProvider?.getPictogramElementForBusinessObject(businessObject)
	}
	
	def getPictogramElement(Diagram diagram, EObject businessObject) {
		diagram.pictogramLinks
			.filter[businessObjects.exists[equals(it, businessObject)]]
			.map[pictogramElement]
			.findFirst[it != null]
	}
	
	def getPictogramElement(IdentifiableElement element) {
		extension val ResourceExtension = new ResourceExtension
		element.eResource.diagram.getPictogramElement(element)
	}
	
	def testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		val bo = pe.businessObject
		bo != null && cls.isAssignableFrom(bo.class)
	}
	
	/**
	 * Retrieves the editing domain of this editor, or {@code null} if not existing
	 * or this editor does not implement the interface
	 * {@code IEditingDomainProvider}.
	 */
	def getEditingDomain(IEditorPart editor) {
		if (editor instanceof IEditingDomainProvider)
			(editor as IEditingDomainProvider).editingDomain
		else null
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
		editor.resource.diagram
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
		editor.resource.graphModel
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
		editor.resource.getContent(modelClass, 1)
	}
	
	def getLinkedGraphModel(Diagram diagram) {
		diagram.businessObject
	}
	
	def refresh(Diagram diagram) {
		async[| diagram.diagramBehavior?.refreshContent ]
	}
	
	def refreshDiagramEditor() {
		async[| activeDiagramEditor?.diagramBehavior?.refresh ]
	}
	
	def refreshDecorators(PictogramElement pe) {
		async[| pe.editor.diagramBehavior?.refreshRenderingDecorators(pe) ]
	}
	
	def getDisplay() {
		Display.current ?: Display.^default
	}
	
	def async(Runnable runnable) {
		display.asyncExec(runnable)
	}
	
	def sync(Runnable runnable) {
		display.syncExec(runnable)
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
		obj.getFile?.openInEditor
	}
}
