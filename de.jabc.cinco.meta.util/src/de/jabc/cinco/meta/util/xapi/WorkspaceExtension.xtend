package de.jabc.cinco.meta.util.xapi

import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.List
import java.util.function.Predicate
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IncrementalProjectBuilder
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.osgi.framework.Bundle
import org.osgi.framework.FrameworkUtil

import static extension org.eclipse.emf.ecore.util.EcoreUtil.getURI

/**
 * Workspace-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class WorkspaceExtension {
	
	/**
	 * Retrieves the current workspace.
	 */
	def getWorkspace() {
		ResourcesPlugin.workspace
	}

	/**
	 * Retrieve the root container of the current workspace that holds all
	 * projects and files.
	 */
	def getWorkspaceRoot() {
		workspace.root
	}
	
	/**
	 * Retrieves the resource for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist.
	 */
	def getIResource(URI uri) {
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
	def getIResource(EObject eobj) {
		eobj.getURI.IResource
	}
	
	/**
	 * Retrieves the file for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	def getFile(URI uri) {
		val res = uri.IResource
		if (res instanceof IFile)
			res as IFile
		else null
	}
	
	/**
	 * Retrieves the file for the specified EObject from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	def getFile(EObject eobj) {
		eobj.getURI.getFile
	}
	
	/**
	 * Creates the specified resource.
	 * Recursively creates its parents as well, if not existent yet.
	 */
	def <T extends IResource> T create(T resource) throws CoreException {
		if (resource == null || resource.exists)
			return resource
		val monitor = new NullProgressMonitor
		if (!resource.parent.exists)
			resource.parent.create
		switch resource.type {
			case IResource.FILE:
				(resource as IFile).create(new ByteArrayInputStream(newByteArrayOfSize(0)), true, monitor)
			case IResource.FOLDER:
				(resource as IFolder).create(IResource.NONE, true, monitor)
			case IResource.PROJECT: {
				(resource as IProject) => [
					create(monitor)
					open(monitor)
				]
			}
		}
		return resource
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * Only replaces its content if the file already exists.
	 */
	def createFile(IContainer container, String name, CharSequence content) {
		container.createFile(name, content?.toString, true)
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * Only replaces its content if the file already exists.
	 */
	def createFile(IContainer container, String name, String content) {
		container.createFile(name, content, true)
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def createFile(IContainer container, String name, String content, boolean createFolders) {
		if (createFolders) {
			val index = name.lastIndexOf("/")
			if (index > -1) {
				val folderPath = name.substring(0, index)
				createFolder(container, folderPath)             
			}
		}
		val file = container.getFile(new Path(name))
		try {
			container.createFile(name, new ByteArrayInputStream(content.getBytes(file.charset)))
		} catch (Exception e) {
			e.printStackTrace()
		}
		return file
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * Only replaces its content if the file already exists.
	 */
	def createFile(IContainer container, String name, InputStream stream) {
		container.createFile(name, stream, true)
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def createFile(IContainer container, String name, InputStream stream, boolean createFolders) {
		if (createFolders) {
			val index = name.lastIndexOf("/")
			if (index > -1) {
				val folderPath = name.substring(0, index)
				container.createFolder(folderPath)
			}
		}
		val file = container.getFile(new Path(name))
		try {
			if (file.exists)
				file.setContents(stream, true, true, null)
			else
				file.create(stream, true, null)
			stream.close
		} catch (Exception e) {
			e.printStackTrace
		}
		return file
	}
	
	/**
	 * Creates a folder with the specified name.
	 */
	def createFolder(IContainer container, String name) {
		container.createFolder(new Path(name))
	}
	
	/**
	 * Creates a folder with the specified path.
	 */
	def createFolder(IContainer container, IPath path) {
		val folder = container.getFolder(path)
		if (!folder.exists) try {
			folder.create()
		} catch (CoreException e) {
			e.printStackTrace
		}
		return folder
	}
	
	/**
	 * Retrieve all files in the container.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class)</code></p>
	 */
	def getFiles(IContainer container) {
		container.getFiles(null)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def getFiles(IContainer container, Predicate<IFile> fileConstraint) {
		container.getResources(IFile, fileConstraint, null)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def getFiles(IContainer container, Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		container.getResources(IFile, fileConstraint, contConstraint)
	}
	
	/**
	 * Retrieves the folder identified by the path of this container that
	 * is interpreted relative to this container's project.
	 * Returns {@code null} if path or folder does not exist.
	 */
	def getFolder(IContainer container) {
		val path = container.projectRelativePath
		if (path == null)
			return null
		container.getFolder(path)
	}
	
	/**
	 * Retrieve all resources of the specified type.
	 * Only recurses through accessible sub-containers.
	 */
	def <T extends IResource> getResources(IContainer container, Class<T> clazz) {
		container.getResources(clazz, null, null)
	}
	
	/**
	 * Retrieve all resources of the specified type that fulfill the specified
	 * resource-related constraint.
	 * Only recurses through accessible sub-containers.
	 */
	def <T extends IResource> getResources(IContainer container, Class<T> clazz, Predicate<T> resConstraint) {
		container.getResources(clazz, resConstraint, null)
	}
	
	/**
	 * Retrieve all resources of the specified type that fulfill the specified
	 * resource-related constraint.
	 * Only recurses through accessible sub-containers that fulfill the
	 * specified container-related constraint.
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
	def <T extends IResource> List<T> getResources(IContainer container, Class<T> clazz, Predicate<T> resConstraint, Predicate<IContainer> contConstraint) {
		val List<T> list = newArrayList
		if (container == null
				|| !container.exists
				|| !container.isAccessible
				|| contConstraint != null && !contConstraint.test(container)) {
			return list
		}
		var IResource[] members = null
		try {
			members = container.members
		} catch (CoreException e) {
			e.printStackTrace();
		}
		if (members != null) {
			for (member : members) {
				if (clazz.isAssignableFrom(member.class)) {
					val T resource = member as T
					if (resConstraint == null || resConstraint.test(resource)) {
						list.add(resource)
					}
				}
				if (member instanceof IContainer) {
					val cont = member as IContainer
					list.addAll(getResources(cont, clazz, resConstraint, contConstraint))
				}
			}
		}
		return list
	}
	
	/**
	 * Creates a {@code Resource} object for the specified URI.
	 * 
	 * @param uri The URI. Must not be {@code null}.
	 * @return the {@code Resource} object, or {@code null} if its creation failed.
	 */
	def createResource(URI uri) {
		extension val ext = new CodingExtension;
		[ (new ResourceSetImpl).getResource(uri, true) ]
			.onException[warn("Failed to create Resource object for URI: " + uri)]
	}
	
	/**
	 * Retrieves the OSGi context of the caller, i.e. the bundle context of its class.
	 */
	def getOSGiContext(Object caller) {
		FrameworkUtil.getBundle(caller.class)?.bundleContext
	}
	
	/**
	 * Retrieves a list of bundle files with specific file extensions.
	 * 
	 * @param bundle  The bundle to be searched through.
	 * @param fileExtension  Must not be {@code null} or empty.
	 * @return  the URIs of the files that match the specified criteria.
	 * @throws IllegalArgumentException  if {@code fileExtension} is {@code null} or empty.
	 */
	def findFiles(Bundle bundle, String fileExtension) {
		extension val ext = new CollectionExtension
		if (fileExtension.nullOrEmpty)
			throw new IllegalArgumentException("fileExtension must not be empty")
   		(bundle.findEntries("/", '''*.«fileExtension»''',true)?.toList ?: newArrayList)
   			.map[toString]
   			.drop[endsWith("/")] // findEntries also lists hidden directories, like .data/
   			.map[URI.createURI(it)]
	}
	
	def cleanAndBuild(IProject it) {
		build(IncrementalProjectBuilder.CLEAN_BUILD, null);
	}
	
	def buildFull(IProject it) {
		build(IncrementalProjectBuilder.FULL_BUILD, null);
	}
	
	def buildIncremental(IProject it) {
		build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
	}
}
