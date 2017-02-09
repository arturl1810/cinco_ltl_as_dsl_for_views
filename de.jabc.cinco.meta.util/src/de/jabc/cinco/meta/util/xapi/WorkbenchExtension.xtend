package de.jabc.cinco.meta.util.xapi

import java.util.function.Predicate
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPathEditorInput
import org.eclipse.ui.PlatformUI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.domain.IEditingDomainProvider

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
		workbench?.activeWorkbenchWindow
	}

	def  getActivePage() {
		activeWorkbenchWindow?.activePage
	}
	
	def  getActiveEditor() {
		activePage?.activeEditor
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
	 * If the editor implements the interface {@code IEditingDomainProvider} the
	 * resource is retrieved directly. If not or if the editing domain is
	 * {@code null}, the resource is retrieved via the underlying file the editor's
	 * input, if existing.
	 */
	def Resource getResource(IEditorPart editor) {
		val domain = editor.editingDomain
		if (domain != null) {
			domain.resourceSet.resources.head
		} else {
			extension val FileExtension = new FileExtension
			editor.file?.resource
		}
	}
	
	/**
	 * Retrieves the editing domain of the specified editor, or {@code null} if
	 * not existing or this editor does not implement the interface
	 * {@code IEditingDomainProvider}.
	 */
	def getEditingDomain(IEditorPart editor) {
		switch editor {
			IEditingDomainProvider: editor.editingDomain
		}
	}
	
	/**
	 * Retrieves the underlying file that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def getFile(IEditorPart editor) {
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
