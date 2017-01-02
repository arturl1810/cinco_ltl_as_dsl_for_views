package de.jabc.cinco.meta.core.utils

import de.jabc.cinco.meta.core.utils.WorkspaceUtil
import java.util.function.Predicate
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.part.MultiPageEditorPart

import static extension de.jabc.cinco.meta.core.utils.eapi.DiagramEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.DiagramEditorEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.FileEAPI.*

/**
 * Workbench-specifc utility methods. 
 * 
 * @author Steve Bosselmann
 */
class WorkbenchUtil {
	
	def static getWorkbench() {
		PlatformUI.workbench
	}
	
	def static getActiveWorkbenchWindow() {
		workbench?.activeWorkbenchWindow
	}

	def static getActivePage() {
		activeWorkbenchWindow?.activePage
	}
	
	def static getActiveEditor() {
		activePage?.activeEditor
	}
	
	def static getEditor(Predicate<IEditorPart> predicate) {
		activePage?.editorReferences
			.findFirst[ref | predicate.test(ref.getEditor(true))]
			.getEditor(true)
	}

	def static getDiagramEditor() {
		val editor = activeEditor
		if (editor == null)
			return null
		if (editor instanceof MultiPageEditorPart) {
			val page = (editor as MultiPageEditorPart).selectedPage
			if (page instanceof DiagramEditor)
				return page as DiagramEditor
		}
		if (editor instanceof DiagramEditor)
			editor as DiagramEditor
		else null
	}
	
	def static getBusinessObject(PictogramElement pe) {
		diagramEditor?.getBusinessObject(pe)
	}
	
	def static getPictogramElement(Object businessObject) {
		diagramEditor?.getPictogramElement(businessObject)
	}

	def static getDiagram() {
		diagramEditor?.diagram
	}
	
	def static getDiagramBehavior() {
		diagramEditor?.diagramBehavior
	}
	
	def static getDiagramTypeProvider() {
		diagramEditor?.diagramTypeProvider
	}
	
	def static getFeatureProvider() {
		diagramTypeProvider.featureProvider
	}
	
	def static getModel() {
		diagramEditor?.model
	}
	
	def static getShapes() {
		diagram?.shapes ?: newArrayList
	}
	
	def static getContainerShapes() {
		diagram?.containerShapes ?: newArrayList
	}
	
	def static testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		val bo = pe.businessObject
		return bo != null && cls.isAssignableFrom(bo.class)
	}
	
	def static refreshDiagram() {
		async[| diagramBehavior?.refreshContent ]
	}
	
	def static refreshDiagramEditor() {
		async[| diagramBehavior?.refresh ]
	}
	
	def static refreshDecorators(PictogramElement pe) {
		async[| diagramBehavior?.refreshRenderingDecorators(pe) ]
	}
	
	def static getDisplay() {
		Display.current ?: Display.^default
	}
	
	def static async(Runnable runnable) {
		display.asyncExec(runnable)
	}
	
	def static sync(Runnable runnable) {
		display.syncExec(runnable)
	}
	
	def static boolean showConfirmDialog(String title, String message) {
		MessageDialog.openConfirm(
				display.activeShell, title, message)
	}
	
	def static void showErrorDialog(String title, String message) {
		MessageDialog.openError(
				display.activeShell, title, message)
	}
	
	def static void showInfoDialog(String title, String message) {
		MessageDialog.openInformation(
				display.activeShell, title, message)
	}
	
	def static boolean showQuestionDialog(String title, String message) {
		MessageDialog.openQuestion(
				display.activeShell, title, message)
	}
	
	def static void showWarningDialog(String title, String message) {
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
	def static IEditorPart openEditor(EObject obj) {
		WorkspaceUtil.getFile(obj)?.openEditor
	}
}