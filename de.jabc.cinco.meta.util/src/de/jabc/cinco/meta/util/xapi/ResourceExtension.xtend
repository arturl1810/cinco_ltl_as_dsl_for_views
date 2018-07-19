package de.jabc.cinco.meta.util.xapi

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
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(Resource resource, Class<T> contentClass) {
		resource.contents
			.filter[contentClass.isAssignableFrom(class)]
			.map[contentClass.cast(it)]
			.head
	}
	
	/**
	 * Retrieves the contained content of the specified type.
	 * It is assumed that one exists at the default index.
	 * However, if the content object at this index is not of appropriate type
	 * all content content objects are searched through and the first occurrence
	 * is returned, if existent.
	 * 
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(Resource resource, Class<T> contentClass, int defaultIndex) {
		val contents = resource.contents
		if (defaultIndex >= 0 && defaultIndex < contents.size) {
			val obj = contents.get(defaultIndex)
			if (contentClass.isAssignableFrom(obj.class))
				return obj as T
		}
		return getContent(resource, contentClass)
	}
		
	/**
	 * Retrieves the IResource pendant for the specified resource,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or the specified URI is not a platform URI.
	 */
	def IResource getIResource(Resource resource) {
		extension val WorkspaceExtension = new WorkspaceExtension
		resource.getURI.IResource
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
		if (resource == null)
			factory.createEditingDomain
		else TransactionUtil.getEditingDomain(resource)
			?: if (resource.resourceSet != null)
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
		transact(resource, null, runnable)
	}
	
	/**
	 * Convenient method to wrap a modification of a {@link Resource} in a
	 * {@link RecordingCommand}.
	 * Retrieves a {@link TransactionalEditingDomain} for the specified object
	 * via {@link TransactionUtil#getEditingDomain(EObject)}. If none is found,
	 * a new one is created.
	 * 
	 * @param resource to be modified.
	 * @param label of the command.
	 * @param runnable that performs the actual modification.
	 */
	def transact(Resource resource, String label, Runnable runnable) {
		val domain = resource.editingDomain
		domain.commandStack.execute(new RecordingCommand(domain) {
			override protected doExecute() {
				try { runnable.run } catch(IllegalStateException e) {
					e.printStackTrace
				}
			}
		} => [
			setLabel(label)
		])
	}
}
