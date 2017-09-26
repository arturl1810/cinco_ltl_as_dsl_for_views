package de.jabc.cinco.meta.runtime.xapi

import graphmodel.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IContainer

/**
 * Workspace-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkspaceExtension extends de.jabc.cinco.meta.util.xapi.WorkspaceExtension {
	
	/**
	 * Retrieves all files in the container, creates the resource for each of them
	 * and retrieves the contained graph model.
	 * It is assumed that a graph model exists and is placed at the default location
	 * (i.e. the second content object of the resource).
	 * However, if the content object at this index is not a graph model all content
	 * objects are searched through for graph models and the first occurrence is
	 * returned, if existent.
	 * 
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * 
	 * @throws NoSuchElementException if the resource does not contain any graph model.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def getGraphModels(IContainer container) {
		container.files.map[getGraphModel(GraphModel)]
	}
	
	/**
	 * Creates the resource for the file and retrieves the contained graph model
	 * of the specified type.
	 * It is assumed that a graph model of the specified type exists and is placed
	 * at the default location (i.e. the second content object of the resource).
	 * However, if the content object at this index is not a graph model of the
	 * specified type all content objects are searched through for graph models
	 * of that type and the first occurrence is returned, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any graph
	 *   model of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends GraphModel> getGraphModel(IFile file, Class<T> modelClass) {
		extension val FileExtension = new FileExtension
		file.getGraphModel(modelClass)
	}
}