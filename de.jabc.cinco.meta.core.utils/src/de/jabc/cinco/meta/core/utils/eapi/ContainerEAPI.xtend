package de.jabc.cinco.meta.core.utils.eapi

import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.List
import java.util.function.Predicate
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workspace.createResource

class ContainerEAPI {
	
	private IContainer container
	
	new(IContainer container) {
		this.container = container
	}
	
	def static eapi(IContainer container) {
		new ContainerEAPI(container)
	}
	
	/**
	 * Creates this resource, if not existent.
	 */
	def create() {
		create(container)
	}
	
	/**
	 * Creates this resource, if not existent.
	 */
	def static create(IContainer container) {
		if (!container.exists) try {
			createResource(container, null)
		} catch (CoreException e) {
			e.printStackTrace
		}
		return container
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * Only replaces its content if the file already exists.
	 */
	def createFile(String name, String content) {
		createFile(container, name, content)
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * Only replaces its content if the file already exists.
	 */
	def static createFile(IContainer container, String name, String content) {
		val file = container.getFile(new Path(name))
		try {
			val stream = new ByteArrayInputStream(content.getBytes(file.charset))
			createFile(container, name, stream)
		} catch (Exception e) {
			e.printStackTrace()
		}
		return file
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def createFile(String name, String content,boolean createFolders) {
		createFile(container, name, content, createFolders)
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def static createFile(IContainer container, String name, String content, boolean createFolders) {
		if (createFolders) {
			val index = name.lastIndexOf("/")
			if (index > -1) {
				val fileName = name.substring(index + 1)
				val folderPath = name.substring(0, index)
				val folder = createFolder(container, folderPath)
				createFile(folder, fileName, content)                 
			}
		}
		return createFile(container, name, content)
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * Only replaces its content if the file already exists.
	 */
	def createFile(String name, InputStream stream) {
		createFile(container, name, stream)
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * Only replaces its content if the file already exists.
	 */
	def static createFile(IContainer container, String name, InputStream stream) {
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
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def createFile(String name, InputStream stream, boolean createFolders) {
		createFile(container, name, stream, createFolders)
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	def static createFile(IContainer container, String name, InputStream stream, boolean createFolders) {
		if (createFolders) {
			val index = name.lastIndexOf("/")
			if (index > -1) {
				val fileName = name.substring(index + 1)
				val folderPath = name.substring(0, index)
				val folder = createFolder(container, folderPath)
				createFile(folder, fileName, stream);
			}
		}
		createFile(container, name, stream);
	}
	
	/**
	 * Creates a folder with the specified name.
	 */
	def IFolder createFolder(String name) {
		createFolder(container, name)
	}
	
	/**
	 * Creates a folder with the specified name.
	 */
	def static createFolder(IContainer container, String name) {
		createFolder(container, new Path(name))
	}
	
	/**
	 * Creates a folder with the specified path.
	 */
	def IFolder createFolder(IPath path) {
		createFolder(container, path)
	}
	
	/**
	 * Creates a folder with the specified path.
	 */
	def static createFolder(IContainer container, IPath path) {
		val folder = container.getFolder(path)
		if (!folder.exists) try {
			createResource(folder, null)
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
	def getFiles() {
		getFiles(container)
	}
	
	/**
	 * Retrieve all files in the container.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class)</code></p>
	 */
	def static getFiles(IContainer container) {
		return getFiles(container, null)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def getFiles(Predicate<IFile> fileConstraint) {
		getFiles(container, fileConstraint)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def static getFiles(IContainer container, Predicate<IFile> fileConstraint) {
		getResources(container, IFile, fileConstraint, null)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def getFiles(Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		getFiles(container, fileConstraint, contConstraint)
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	def static getFiles(IContainer container, Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		getResources(container, IFile, fileConstraint, contConstraint)
	}
	
	/**
	 * Retrieves the folder identified by the path of this container that
	 * is interpreted relative to this container's project.
	 * Returns {@code null} if path or folder does not exist.
	 */
	def getFolder() {
		getFolder(container)
	}
	
	/**
	 * Retrieves the folder identified by the path of this container that
	 * is interpreted relative to this container's project.
	 * Returns {@code null} if path or folder does not exist.
	 */
	def static getFolder(IContainer container) {
		val path = container.projectRelativePath
		if (path == null)
			return null
		container.getFolder(path)
	}
	
	/**
	 * Retrieve all resources of the specified type.
	 * Only recurses through accessible sub-containers.
	 */
	def <T extends IResource> List<T> getResources(Class<T> clazz) {
		return getResources(container, clazz)
	}
	
	/**
	 * Retrieve all resources of the specified type.
	 * Only recurses through accessible sub-containers.
	 */
	def static <T extends IResource> getResources(IContainer container, Class<T> clazz) {
		return getResources(container, clazz, null, null);
	}
	
	/**
	 * Retrieve all resources of the specified type that fulfill the specified
	 * resource-related constraint.
	 * Only recurses through accessible sub-containers.
	 */
	def <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<T> resConstraint) {
		return getResources(container, clazz, resConstraint);
	}
	
	/**
	 * Retrieve all resources of the specified type that fulfill the specified
	 * resource-related constraint.
	 * Only recurses through accessible sub-containers.
	 */
	def static <T extends IResource> getResources(IContainer container, Class<T> clazz, Predicate<T> resConstraint) {
		return getResources(container, clazz, resConstraint, null);
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
	def <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<T> resConstraint, Predicate<IContainer> contConstraint) {
		return getResources(container, clazz, resConstraint, contConstraint);
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
	def static <T extends IResource> List<T> getResources(IContainer container, Class<T> clazz, Predicate<T> resConstraint, Predicate<IContainer> contConstraint) {
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
			for (Object member : members) {
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
}