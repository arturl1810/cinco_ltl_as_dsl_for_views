package de.jabc.cinco.meta.core.utils.eapi

import de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.Edit
import graphmodel.GraphModel
import java.util.NoSuchElementException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.util.TransactionUtil
import org.eclipse.graphiti.mm.pictograms.Diagram

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.*

class ResourceEAPI {
	
	private Resource resource;

	new(Resource resource) {
		this.resource = resource;
	}
	
	def static eapi(Resource resource) {
		new ResourceEAPI(resource)
	}
	
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
	def Diagram getDiagram() {
		getDiagram(resource)
	}
	
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
	def static Diagram getDiagram(Resource resource) {
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
	def getGraphModel() {
		getGraphModel(resource)
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
	def static getGraphModel(Resource resource) {
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
	def <T extends GraphModel> getGraphModel(Class<T> modelClass) {
		getGraphModel(resource, modelClass)
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
	def static <T extends GraphModel> getGraphModel(Resource resource, Class<T> modelClass) {
		getContent(resource, modelClass, 1);
	}
	
	/**
	 * Creates the resource for this file and returns the contained content of
	 * the specified type by searching through all content objects and the first
	 * occurrence, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(Class<T> contentClass) {
		getContent(resource, contentClass)
	}
	
	/**
	 * Creates the resource for this file and returns the contained content of
	 * the specified type by searching through all content objects and the first
	 * occurrence, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def static <T extends EObject> T getContent(Resource resource, Class<T> contentClass) {
		try {
			val opt = resource.getContents().stream()
				.filter[c | contentClass.isAssignableFrom(c.getClass())]
				.map[o | contentClass.cast(o)]
				.findFirst()
			if (opt.isPresent())
				return opt.get()
			else throw new NoSuchElementException(
				"No content of type " + contentClass + " found in file: " + resource);
		} catch(RuntimeException re) {
			throw re;
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + resource, e);
		}
	}
	
	/**
	 * Retrieves the contained content of the specified type.
	 * It is assumed that one exists at the default index.
	 * However, if the content object at this index is not of appropriate type
	 * all content content objects are searched through and the first occurrence
	 * is returned, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(Class<T> contentClass, int defaultIndex) {
		getContent(resource, contentClass, defaultIndex)
	}
	
	/**
	 * Retrieves the contained content of the specified type.
	 * It is assumed that one exists at the default index.
	 * However, if the content object at this index is not of appropriate type
	 * all content content objects are searched through and the first occurrence
	 * is returned, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def static <T extends EObject> T getContent(Resource resource, Class<T> contentClass, int defaultIndex) {
		try {
			val EList<EObject> objs = resource.getContents()
			if (defaultIndex >= 0 && defaultIndex < objs.size) {
				val obj = objs.get(defaultIndex)
				if (contentClass.isAssignableFrom(obj.class)) {
					val retVal = obj as T
					return retVal as T
				}
			}
			return getContent(resource, contentClass)
		} catch(RuntimeException re) {
			throw re
		} catch(Exception e) {
			e.printStackTrace()
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + resource, e)
		}
	}
			
	/**
	 * Retrieves the IResource pendant for the specified resource,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or the specified URI is not a platform URI.
	 */
	def IResource getIResource() {
		getIResource(resource)
	}
			
	/**
	 * Retrieves the IResource pendant for the specified resource,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or the specified URI is not a platform URI.
	 */
	def static IResource getIResource(Resource resource) {
		return getResource(resource.URI)
	}
	
	/**
	 * Retrieves the file for this resource, if existent.
	 * Returns {@code null} if the file does not exist.
	 */
	def IFile getFile() {
		getFile(resource)
	}
	
	/**
	 * Retrieves the file for this resource, if existent.
	 * Returns {@code null} if the file does not exist.
	 */
	def static getFile(Resource resource) {
		val res = getIResource(resource)
		if (res instanceof IFile) res else null
	}

	/**
	 * Retrieves the project this resource is located in, if existent.
	 * Returns {@code null} if the resource or the project does not exist.
	 */
	def getProject() {
		getProject(resource)
	}

	/**
	 * Retrieves the project this resource is located in, if existent.
	 * Returns {@code null} if the resource or the project does not exist.
	 */
	def static getProject(Resource resource) {
		getIResource(resource)?.project
	}
	
	/**
	 * Retrieves the editing domain of this resource, if existent.
	 * Otherwise creates a new editing domain using the 
	 * {@code TransactionalEditingDomain.Factory}
	 */
	def getEditingDomain() {
		getEditingDomain(resource)
	}
	
	/**
	 * Retrieves the editing domain of this resource, if existent.
	 * Otherwise creates a new editing domain using the 
	 * {@code TransactionalEditingDomain.Factory}
	 */
	def static getEditingDomain(Resource resource) {
		val factory = TransactionalEditingDomain.Factory.INSTANCE
		TransactionUtil.getEditingDomain(resource) ?:
			if (resource.resourceSet != null)
				factory.createEditingDomain(resource.resourceSet)
			else
				factory.createEditingDomain
	}
	
	/**
	 * Convenient method to wrap a modification of an EObject in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param obj  The object for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	def Edit edit() {
		edit(resource)
	}
	
	/**
	 * Convenient method to wrap a modification of an EObject in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param obj  The object for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	def static Edit edit(Resource res) {[
		val domain = getEditingDomain(res)
		domain.commandStack.execute(new RecordingCommand(domain) {
			override protected doExecute() {
				try { run } catch(IllegalStateException e) {
					e.printStackTrace
				}
			}
		})
	]}
	
	/**
	 * Convenient method to wrap a modification of an EObject in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param obj  The object for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	def static Edit edit(EObject obj) {
		edit(obj.eResource)
	}
	
	@FunctionalInterface
	static interface Edit {
		def void transact(Runnable runnable)
	}
}