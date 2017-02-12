package de.jabc.cinco.meta.runtime.xapi

import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.emf.ecore.resource.Resource
import graphmodel.GraphModel

/**
 * Resource-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class ResourceExtension extends de.jabc.cinco.meta.util.xapi.ResourceExtension {
	
	/**
	 * Retrieves the contained diagram.
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
	def Diagram getDiagram(Resource resource) {
		getContent(resource, Diagram, 0)
	}
	
	/**
	 * Retrieves the contained graph model.
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
	def getGraphModel(Resource resource) {
		getContent(resource, GraphModel, 1)
	}
	
	/**
	 * Retrieves the contained graph model of the specified type.
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
	def <T extends GraphModel> getGraphModel(Resource resource, Class<T> modelClass) {
		getContent(resource, modelClass, 1);
	}
}