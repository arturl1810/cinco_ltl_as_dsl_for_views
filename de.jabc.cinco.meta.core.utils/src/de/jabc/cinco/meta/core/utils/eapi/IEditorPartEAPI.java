package de.jabc.cinco.meta.core.utils.eapi;

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.getFiles;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;
import graphmodel.GraphModel;

import java.util.List;
import java.util.NoSuchElementException;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPathEditorInput;

public class IEditorPartEAPI {
	
	private IEditorPart editor;

	public IEditorPartEAPI(IEditorPart editor) {
		this.editor = editor;
	}
	
	/**
	 * Retrieves the project that the underlying resource representing this editor's
	 * input is associated with, or {@code null} if not existing.
	 */
	public IProject getProject() {
		Resource res = getResource();
		if (res != null)
			return eapi(getResource()).getProject();
		
		return null;
	}
	
	/**
	 * Retrieves the underlying resource that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	public Resource getResource() {
		EditingDomain ed = getEditingDomain();
		if (ed != null)
			return ed.getResourceSet().getResources().get(0);
		
		IFile file = getFile();
		if (file != null)
			return eapi(file).getResource();
			
		return null;
	}
	
	/**
	 * Retrieves the underlying file that represents this editor's input, or
	 * {@code null} if not existing.
	 */
	public IFile getFile() {
		IEditorInput editorInput = editor.getEditorInput();
		if (editorInput instanceof IPathEditorInput) {
			IPath editorPath = ((IPathEditorInput) editorInput).getPath();
			List<IFile> files = getFiles(f -> 
				   f.getFullPath().equals(editorPath)
				|| f.getLocation().equals(editorPath));
			
			if (files.size() == 1)
				return files.get(0);
		}
		return null;
	}
	
	/**
	 * Retrieves the editing domain of this editor, or {@code null} if not existing
	 * or this editor does not implement the interface
	 * {@code IEditingDomainProvider}.
	 */
	public EditingDomain getEditingDomain() {
		return editor instanceof IEditingDomainProvider
			? ((IEditingDomainProvider) editor).getEditingDomain()
			: null;
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
	public Diagram getDiagram() {
		return eapi(getResource()).getContent(Diagram.class, 0);
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
	public GraphModel getGraphModel() {
		return eapi(getResource()).getContent(GraphModel.class, 1);
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
	public <T extends GraphModel> T getGraphModel(Class<T> modelClass) {
		return eapi(getResource()).getContent(modelClass, 1);
	}
}