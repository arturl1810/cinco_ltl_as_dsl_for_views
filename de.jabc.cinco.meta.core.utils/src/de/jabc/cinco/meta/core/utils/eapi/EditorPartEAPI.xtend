package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.GraphModel
import org.eclipse.emf.edit.domain.IEditingDomainProvider
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPathEditorInput

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workspace.getFiles

import static extension de.jabc.cinco.meta.core.utils.eapi.FileEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.*

class EditorPartEAPI {
	
	private IEditorPart editor

	new(IEditorPart editor) {
		this.editor = editor
	}
	
	def static eapi(IEditorPart editor) {
		new EditorPartEAPI(editor)
	}
	
	/**
	 * Retrieves the project that the underlying resource representing this editor's
	 * input is associated with, or {@code null} if not existing.
	 */
	def getProject() {
		getProject(editor)
	}
	
	/**
	 * Retrieves the project that the underlying resource representing this editor's
	 * input is associated with, or {@code null} if not existing.
	 */
	def static getProject(IEditorPart editor) {
		val res = editor.resource
		if (res != null)
			editor.resource.project
		else null
	}
	
	/**
	 * Retrieves the underlying resource that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def getResource() {
		getResource(editor)
	}
	
	/**
	 * Retrieves the underlying resource that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def static getResource(IEditorPart editor) {
		val ed = getEditingDomain(editor)
		if (ed != null)
			ed.resourceSet.resources.head
		editor.file?.resource
	}
	
	/**
	 * Retrieves the underlying file that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def getFile() {
		getFile(editor)
	}
	
	/**
	 * Retrieves the underlying file that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	def static getFile(IEditorPart editor) {
		val editorInput = editor.editorInput
		if (editorInput instanceof IPathEditorInput) {
			val editorPath = (editorInput as IPathEditorInput).path
			val files = getFiles(f | f.fullPath == editorPath || f.location == editorPath)
			if (files.size() == 1)
				return files.get(0)
		}
		return null
	}
	
	/**
	 * Retrieves the editing domain of this editor, or {@code null} if not existing
	 * or this editor does not implement the interface
	 * {@code IEditingDomainProvider}.
	 */
	def getEditingDomain() {
		getEditingDomain(editor)
	}
	
	/**
	 * Retrieves the editing domain of this editor, or {@code null} if not existing
	 * or this editor does not implement the interface
	 * {@code IEditingDomainProvider}.
	 */
	def static getEditingDomain(IEditorPart editor) {
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
	def getDiagram() {
		getDiagram(editor)
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
	def static getDiagram(IEditorPart editor) {
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
	def getGraphModel() {
		getGraphModel(editor)
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
	def static getGraphModel(IEditorPart editor) {
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
	def <T extends GraphModel> T getGraphModel(Class<T> modelClass) {
		getGraphModel(editor, modelClass)
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
	def static <T extends GraphModel> T getGraphModel(IEditorPart editor, Class<T> modelClass) {
		editor.resource.getContent(modelClass, 1)
	}
}