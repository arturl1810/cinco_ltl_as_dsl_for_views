package de.jabc.cinco.meta.util.xapi

import java.util.function.Predicate
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPathEditorInput
import org.eclipse.ui.PlatformUI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.domain.IEditingDomainProvider
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.emf.common.util.URI
import org.eclipse.ui.IEditorInput
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.ui.IURIEditorInput
import org.eclipse.core.resources.IFile
import java.net.URL

import static extension org.eclipse.emf.common.util.URI.createURI
import static extension org.eclipse.emf.common.util.URI.createPlatformResourceURI
import org.eclipse.ui.part.FileEditorInput

/**
 * Workbench-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkbenchExtension {
	
	/**
	 * Retrieves the current workbench.
	 * 
	 * @return The current workbench. Might be {@code null}.
	 */
	def getWorkbench() {
		PlatformUI.workbench
	}
	
	/**
	 * Retrieves the active window of the workbench.
	 * 
	 * @return The active window, or {@code null} if it cannot be retrieved for
	 *   whatever reason.
	 */
	def  getActiveWorkbenchWindow() {
		workbench?.activeWorkbenchWindow
	}

	/**
	 * Retrieves the active page of the active workbench window.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return The active page, or {@code null} if it cannot be retrieved for
	 *   whatever reason.
	 */
	def  getActivePage() {
		activeWorkbenchWindow?.activePage
	}
	
	/**
	 * Retrieves the active editor in the active page of the active workbench window.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return The active editor, or {@code null} if it cannot be retrieved for
	 *   whatever reason.
	 */
	def  getActiveEditor() {
		activePage?.activeEditor
	}
	
	/**
	 * Retrieves the first editor in the active page of the active workbench window,
	 * iff it fulfills the specified predicate.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @return The first editor that fulfills the specified predicate, or {@code null}
	 *   if none is found or an editor cannot be retrieved for whatever reason.
	 */
	def  getEditor(Predicate<IEditorPart> predicate) {
		activePage?.editorReferences.findFirst[ref |
			predicate.test(ref.getEditor(true))
		]?.getEditor(true)
	}
	
	/**
	 * Retrieves the project that the resource currently edited in the specified
	 * editor is associated with.
	 * 
	 * @param editor for which to retrieve the associated project.
	 * @return The project corresponding to the editor, or {@code null} if not
	 *   existing.
	 */
	def getProject(IEditorPart editor) {
		val res = editor.resource
		if (res != null) {
			extension val ResourceExtension = new ResourceExtension
			res.project
		}
		else null
	}
	
	/**
	 * Retrieves the resource currently edited in the specified editor.
	 * If the editor implements the interface {@code IEditingDomainProvider} the
	 * resource is retrieved directly. If not or if the editing domain is
	 * {@code null}, the resource is retrieved via the file that is the input of
	 * the specified editor.
	 * Returns {@code null} if any of these entities cannot be retrieved instead
	 * of throwing exceptions.
	 * 
	 * @param editor for which to retrieve the associated resource.
	 * @return The resource corresponding to the editor, or {@code null} if not
	 *   existing.
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
	 * Retrieves the editing domain of the specified editor.
	 * 
	 * @param editor for which to retrieve the associated editing domain.
	 * @return The editing domain of the specified editor, or {@code null} if
	 * not existing or the editor does not implement the interface
	 * {@link IEditingDomainProvider}.
	 */
	def getEditingDomain(IEditorPart editor) {
		switch editor {
			IEditingDomainProvider: editor.editingDomain
		}
	}
	
	/**
	 * Retrieves the file that represents the input of the specified editor.
	 * 
	 * @param editor for which to retrieve the associated input file.
	 * @return The file that represents the input of the specified editor or
	 * {@code null} if not existing or the editor does not implement the interface
	 * {@link IPathEditorInput}.
	 */
	def getFile(IEditorPart editor) {
		switch input : editor?.editorInput {
			FileEditorInput: input.file
			IPathEditorInput: {
				extension val WorkspaceExtension = new WorkspaceExtension
				val files = workspaceRoot.getFiles[
					fullPath == input.path || location == input.path
				]
				if (files.size == 1)
					return files.get(0)
			}
		}
	}
	
	/**
	 * Retrieves the URI of the input of an editor. This can be both, the URI of a
	 * file in the workspace (input is {@link IURIEditorInput}) as well an abstract
	 * URI pointing to a resource in an archive or anywhere else (input is
	 * {@link IAdaptable}).
	 * 
	 * @param input of the editor.
	 * @return The URI of the input.
	 */
	def URI getURI(IEditorInput input) {
		switch input {
			IURIEditorInput: createURI(new URL(input.URI.toString).toString)
			IAdaptable: {
				val file = input.getAdapter(IFile)
				if (file != null) {
					new ResourceSetImpl().getURIConverter().normalize(
						createPlatformResourceURI(file.fullPath.toString, true)
					)
				}
			}
		}
	}
	
	/**
	 * Convenient method to wrap a modification of an {@link EObject} in a
	 * {@link RecordingCommand}.
	 * Retrieves a {@link TransactionalEditingDomain} for the specified object
	 * via {@link TransactionUtil#getEditingDomain(EObject)}. If none is found,
	 * a new one is created.
	 * 
	 * @param object to be modified.
	 * @param runnable that performs the actual modification.
	 */
	def transact(EObject object, Runnable runnable) {
		transact(object, null, runnable)
	}
	
	/**
	 * Convenient method to wrap a modification of an {@link EObject} in a
	 * {@link RecordingCommand}.
	 * Retrieves a {@link TransactionalEditingDomain} for the specified object
	 * via {@link TransactionUtil#getEditingDomain(EObject)}. If none is found,
	 * a new one is created.
	 * 
	 * @param object to be modified.
	 * @param runnable that performs the actual modification.
	 */
	def transact(EObject object, String label, Runnable runnable) {
		extension val ResourceExtension = new ResourceExtension
		object.eResource.transact(label, runnable)
	}
}
