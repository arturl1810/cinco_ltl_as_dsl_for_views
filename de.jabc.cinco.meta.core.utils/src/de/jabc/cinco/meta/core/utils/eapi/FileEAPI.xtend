package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.ui.PartInitException
import org.eclipse.ui.ide.IDE

import static extension de.jabc.cinco.meta.core.utils.eapi.EditorPartEAPI.*
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.*

class FileEAPI {
	
	private IFile file

	new(IFile file) {
		this.file = file;
	}
	
	def static eapi(IFile file) {
		new FileEAPI(file)
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
	def getDiagram() {
		getDiagram(file)
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
	def static getDiagram(IFile file) {
		getResourceContent(file, Diagram, 0)
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
	def getGraphModel() {
		getGraphModel(file)
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
	def static getGraphModel(IFile file) {
		getResourceContent(file, GraphModel, 1)
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
	def <T extends GraphModel> getGraphModel(Class<T> modelClass) {
		return getGraphModel(file, modelClass)
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
	def static <T extends GraphModel> getGraphModel(IFile file, Class<T> modelClass) {
		getResourceContent(file, modelClass, 1)
	}
	
	def getResource() {
		getResource(file)
	}
	
	def static getResource(IFile file) {
		new ResourceSetImpl().getResource(file.getPlatformResourceURI, true)
	}
	
	def URI getPlatformResourceURI() {
		getPlatformResourceURI(file)
	}
	
	def static URI getPlatformResourceURI(IFile file) {
		URI.createPlatformResourceURI(file.fullPath.toOSString, true)
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
	def <T extends EObject> getResourceContent(Class<T> contentClass) {
		getResourceContent(file, contentClass)
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
	def static <T extends EObject> getResourceContent(IFile file, Class<T> contentClass) {
		try {
			file.resource.getContent(contentClass)
		} catch(RuntimeException re) {
			throw re
		} catch(Exception e) {
			e.printStackTrace()
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + file, e)
		}
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
	def <T extends EObject> T getResourceContent(Class<T> contentClass, int defaultIndex) {
		getResourceContent(file, contentClass, defaultIndex)
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
	def static <T extends EObject> T getResourceContent(IFile file, Class<T> contentClass, int defaultIndex) {
		try {
			file.resource.getContent(contentClass, defaultIndex)
		} catch(RuntimeException re) {
			throw re;
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + file, e);
		}
	}
	
	/**
	 * Retrieves the editor whose input is this file, if existent.
	 */
	def getEditor() {
		getEditor(file)
	}
	
	/**
	 * Retrieves the editor whose input is this file, if existent.
	 */
	def static getEditor(IFile file) {
		Cinco.Workbench.getEditor(editor | editor.resource == file.resource)
	}
	
	/**
	 * Open a new editor for the specified file in the active page of the
	 * active workbench window.
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized
	 */
	def openEditor() throws PartInitException {
		openEditor(file)
	}
	
	/**
	 * Open a new editor for the specified file in the active page of the
	 * active workbench window.
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized
	 */
	def static openEditor(IFile file) {
		IDE.openEditor(Cinco.Workbench.activePage, file)
	}
}