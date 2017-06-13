package de.jabc.cinco.meta.util.xapi

import java.util.NoSuchElementException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.util.TransactionUtil

/**
 * Resource-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class ResourceExtension {
	
	/**
	 * Creates the resource for this file and returns the contained content of
	 * the specified type by searching through all content objects and the first
	 * occurrence, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(Resource resource, Class<T> contentClass) {
		try {
			val opt = resource.contents.stream
				.filter[c | contentClass.isAssignableFrom(c.class)]
				.map[o | contentClass.cast(o)]
				.findFirst
			if (opt.isPresent)
				return opt.get
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
	def <T extends EObject> T getContent(Resource resource, Class<T> contentClass, int defaultIndex) {
		try {
			val objs = resource.contents
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
	def IResource getIResource(Resource resource) {
		extension val WorkspaceExtension = new WorkspaceExtension
		resource.getURI.resource
	}
	
	/**
	 * Retrieves the file for this resource, if existent.
	 * Returns {@code null} if the file does not exist.
	 */
	def getFile(Resource resource) {
		val res = getIResource(resource)
		if (res instanceof IFile) res else null
	}

	/**
	 * Retrieves the project this resource is located in, if existent.
	 * Returns {@code null} if the resource or the project does not exist.
	 */
	def getProject(Resource resource) {
		getIResource(resource)?.project
	}
	
	/**
	 * Retrieves the editing domain of this resource, if existent.
	 * Otherwise creates a new editing domain using the 
	 * {@code TransactionalEditingDomain.Factory}
	 */
	def getEditingDomain(Resource resource) {
		val factory = TransactionalEditingDomain.Factory.INSTANCE
		TransactionUtil.getEditingDomain(resource) ?:
			if (resource.resourceSet != null)
				factory.createEditingDomain(resource.resourceSet)
			else
				factory.createEditingDomain
	}
	
	/**
	 * Retrieves the editor the specified resource is currently edited in, if existent.
	 */
	def getEditor(Resource res) {
		extension val ext = new WorkbenchExtension
		getEditor[resource == res]
	}
	
	/**
	 * Convenient method to wrap a modification of a {@link Resource} in a
	 * {@link RecordingCommand}.
	 * Retrieves a {@link TransactionalEditingDomain} for the specified object
	 * via {@link TransactionUtil#getEditingDomain(EObject)}. If none is found,
	 * a new one is created.
	 * 
	 * @param resource to be modified.
	 * @param runnable that performs the actual modification.
	 */
	def transact(Resource resource, Runnable runnable) {
		val domain = resource.editingDomain
		domain.commandStack.execute(new RecordingCommand(domain) {
			override protected doExecute() {
				try { runnable.run } catch(IllegalStateException e) {
					e.printStackTrace
				}
			}
		})
	}
}
