package de.jabc.cinco.meta.runtime.xapi

import org.eclipse.core.resources.IFile
import org.eclipse.graphiti.mm.pictograms.Diagram
import graphmodel.GraphModel
import graphmodel.internal.InternalGraphModel

/**
 * File-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class FileExtension extends de.jabc.cinco.meta.util.xapi.FileExtension {
	
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
	def getDiagram(IFile file) {
		getContent(file, Diagram, 0)
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
	def getGraphModel(IFile file) {
		getContent(file, InternalGraphModel, 1).element
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
	def <T extends GraphModel> getGraphModel(IFile file, Class<T> modelClass) {
		getContent(file, modelClass, 1)
	}
}
