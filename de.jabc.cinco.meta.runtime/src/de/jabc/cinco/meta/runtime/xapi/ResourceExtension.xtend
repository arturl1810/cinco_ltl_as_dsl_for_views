package de.jabc.cinco.meta.runtime.xapi

import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.emf.ecore.resource.Resource
import graphmodel.GraphModel
import graphmodel.internal.InternalGraphModel

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
	 * @return The diagram, or {@code null} if not existent.
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
	 * @return The graph model, or {@code null} if not existent.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def getGraphModel(Resource resource) {
		getContent(resource, InternalGraphModel, 1)?.element
	}
	
	/**
	 * Returns {@code true} if the resource contains a graph model,
	 * {@code false} otherwise.
	 */
	def containsGraphModel(Resource resource) {
		resource.graphModel != null
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
	 * @return The diagram, or {@code null} if the resource does not contain any
	 *   graph model of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends GraphModel> getGraphModel(Resource resource, Class<T> modelClass) {
		val model = resource.getGraphModel
		if (model?.eClass?.name == modelClass.simpleName) {
			return model as T
		}
	}
	
	/**
	 * Returns {@code true} if the resource contains a graph model of the specified
	 * type, {@code false} otherwise.
	 */
	def <T extends GraphModel> containsGraphModel(Resource resource, Class<T> modelClass) {
		resource.getGraphModel(modelClass) != null
	}
}
