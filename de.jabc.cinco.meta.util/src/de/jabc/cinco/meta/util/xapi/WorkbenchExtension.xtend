package de.jabc.cinco.meta.util.xapi

import java.util.function.Predicate
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPathEditorInput
import org.eclipse.ui.PlatformUI
import org.eclipse.emf.ecore.EObject

/**
 * Workbench-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkbenchExtension {
	
	def getWorkbench() {
		PlatformUI.workbench
	}
	
	def  getActiveWorkbenchWindow() {
		val wb = workbench
		println("Workbench: " + wb)
		wb?.activeWorkbenchWindow
	}

	def  getActivePage() {
		val ww = activeWorkbenchWindow
		println("Active activeWorkbenchWindow: " + ww)
		ww?.activePage
	}
	
	def  getActiveEditor() {
		val page = activePage
		println("Active page: " + page)
		page?.activeEditor
	}
	
	def  getActiveEditor(Predicate<IEditorPart> predicate) {
		activePage?.editorReferences.findFirst[ref |
			predicate.test(ref.getEditor(true))
		]?.getEditor(true)
	}
	
	/**
	 * Retrieves the project that the underlying resource representing this editor's
	 * input is associated with, or {@code null} if not existing.
	 */
	def getProject(IEditorPart editor) {
		val res = editor.resource
		if (res != null) {
			extension val ResourceExtension = new ResourceExtension
			editor.resource.project
		}
		else null
	}
	
	/**
	 * Retrieves the underlying resource that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def Resource getResource(IEditorPart editor) {
		println("Get editor resoure")
		extension val FileExtension = new FileExtension
		editor.file?.resource
	}
	
	/**
	 * Retrieves the underlying file that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def getFile(IEditorPart editor) {
		println("Get editor file")
		val editorInput = editor.editorInput
		if (editorInput instanceof IPathEditorInput) {
			val editorPath = (editorInput as IPathEditorInput).path
			extension val WorkspaceExtension = new WorkspaceExtension
			val files = workspaceRoot.getFiles[IFile f | f.fullPath == editorPath || f.location == editorPath]
			if (files.size() == 1)
				return files.get(0)
		}
		return null
	}
	
	def transact(EObject obj, Runnable runnable) {
		extension val ResourceExtension = new ResourceExtension
		obj.eResource.transact(runnable)
	}
}
