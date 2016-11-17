package de.jabc.cinco.meta.core.utils.eapi;

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;
import graphmodel.GraphModel;

import java.util.NoSuchElementException;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;

/**
 * Extension of the IFile API
 */
public class IFileEAPI {
	
	private IFile file;

	public IFileEAPI(IFile file) {
		this.file = file;
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained diagram.
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
		return getResourceContent(Diagram.class, 0);
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained graph model.
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
		return getResourceContent(GraphModel.class, 1);
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained graph model
	 * of the specified type.
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
		return getResourceContent(modelClass, 1);
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained content of
	 * the specified type. It is assumed that one exists at the default index.
	 * However, if the content object at this index is not of appropriate type
	 * all content content objects are searched through and the first occurrence
	 * is returned, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	public <T extends EObject> T getResourceContent(Class<T> contentClass, int defaultIndex) {
		try {
			return eapi(getResource()).getContent(contentClass, defaultIndex);
		} catch(RuntimeException re) {
			throw re;
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + file, e);
		}
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained content of
	 * the specified type by searching through all content objects and the first
	 * occurrence, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	public <T extends EObject> T getResourceContent(Class<T> contentClass) {
		try {
			return eapi(getResource()).getContent(contentClass);
		} catch(RuntimeException re) {
			throw re;
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + file, e);
		}
	}
	
	public Resource getResource() {
		return new ResourceSetImpl().getResource(
				getPlatformResourceURI(), true);
	}
	
	public URI getPlatformResourceURI() {
		return URI.createPlatformResourceURI(
				file.getFullPath().toOSString(), true);
	}
	
	/**
	 * Open a new editor for the specified file in the active page of the
	 * active workbench window.
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized
	 */
	public IEditorPart openEditor() throws PartInitException {
		return IDE.openEditor(
			PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage(),
			file);
	}
}