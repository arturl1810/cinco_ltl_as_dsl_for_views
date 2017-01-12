package de.jabc.cinco.meta.core.utils

import java.io.ByteArrayInputStream
import java.util.List
import java.util.function.Predicate
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject

import static org.eclipse.core.resources.ResourcesPlugin.getWorkspace
import static extension de.jabc.cinco.meta.core.utils.eapi.ContainerEAPI.*
import static extension org.eclipse.emf.ecore.util.EcoreUtil.getURI

/**
 * Workspace-specific utility methods.
 * 
 * @author Steve Bosselmann
 */
class WorkspaceUtil {
	
	/**
	 * Creates the specified resource.
	 * Recursively creates its parents as well, if not existent yet.
	 */
	def static <T extends IResource> T createResource(T resource, IProgressMonitor monitor) throws CoreException {
		if (resource == null || resource.exists)
			return resource
		if (!resource.parent.exists)
			createResource(resource.parent, monitor)
		if (resource.type == IResource.FILE) {
			(resource as IFile).create(
				new ByteArrayInputStream(newByteArrayOfSize(0)), true, monitor)
		}
		else if (resource.type == IResource.FOLDER) {
			(resource as IFolder).create(IResource.NONE, true, monitor)
		}
		else if (resource.type == IResource.PROJECT) {
			(resource as IProject).create(monitor)
			(resource as IProject).open(monitor)
		}
		return resource
	}

	/**
	 * Retrieve all files in the workspace.
	 * Only recurses through accessible containers (e.g. open projects).
	 */
	def static getFiles() {
		workspace.root.files
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 */
	def static getFiles(Predicate<IFile> fileConstraint) {
		workspace.root.getFiles(fileConstraint, null)
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 */
	def static getFiles(Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		workspace.root.getFiles(fileConstraint, contConstraint)
	}
	
	/**
	 * Retrieve all resources in the workspace of the specified type
	 * that fulfill the specified resource-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 * <p>
	 * Example: Recursively retrieve derived files from folders:
	 * <pre><code>
	 * getResource(IFile.class,
	 *   file -> file.isDerived(),
	 *   cont -> cont instanceof IFolder
	 * )
	 * </code></pre>
	 * </p>
	 */
	def static <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<IContainer> contConstraint, Predicate<T> resConstraint) {
		workspace.root.getResources(clazz, resConstraint, contConstraint)
	}
	
	/**
	 * Retrieves the resource for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist.
	 */
	def static getResource(URI uri) {
		if (uri != null) {
			workspace.root.findMember(
				if (uri.isPlatformResource)
					uri.toPlatformString(true)
				else uri.path)
		}
	}
	
	/**
	 * Retrieves the resource for the specified object from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist.
	 */
	def static getResource(EObject eobj) {
		getResource(eobj.URI)
	}
	
	/**
	 * Retrieves the file for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	def static getFile(URI uri) {
		val res = getResource(uri)
		if (res instanceof IFile)
			res as IFile
		else null
	}
	
	/**
	 * Retrieves the file for the specified EObject from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	def static getFile(EObject eobj) {
		getFile(eobj.URI)
	}
}