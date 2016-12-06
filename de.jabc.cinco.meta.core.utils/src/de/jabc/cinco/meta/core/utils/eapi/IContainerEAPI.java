package de.jabc.cinco.meta.core.utils.eapi;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;

import de.jabc.cinco.meta.core.utils.WorkspaceUtil;

/**
 * Extension of the IContainer API
 */
public class IContainerEAPI {
	
	private IContainer container;
	private IProgressMonitor progressMonitor;

	public IContainerEAPI(IContainer container) {
		this.container = container;
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * Only replaces its content if the file already exists.
	 */
	public IFile createFile(String name, String content) {
		IFile file = container.getFile(new Path(name));			
		try {
			return createFile(name, new ByteArrayInputStream(content.getBytes(file.getCharset())));
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return file;
	}
	
	/**
	 * Creates a file with the specified name and content.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	public IFile createFile(String name, String content,boolean createFolders) {
		int index = name.lastIndexOf("/");
		if(index>-1){
			String fileName = name.substring(index+1);
			String fodlerPath = name.substring(0, index);
			return WorkspaceUtil.eapi(this.createFolder(fodlerPath)).createFile(fileName, content);
		}
		return createFile(name, content);
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * Only replaces its content if the file already exists.
	 */
	public IFile createFile(String name, InputStream stream) {
		IFile file = container.getFile(new Path(name));
		try {
			if (file.exists()) 
				file.setContents(stream, true, true, progressMonitor);
			else
				file.create(stream, true, progressMonitor);
			stream.close();
		} catch (final Exception e) {
			e.printStackTrace();
		}
		return file;
	}
	
	/**
	 * Creates a file with the specified name and content provided
	 * by the specified input stream.
	 * @param createFolders decides whether all folders in the given name are created
	 */
	public IFile createFile(String name, InputStream stream, boolean createFolders) {
		int index = name.lastIndexOf("/");
		if(index>-1){
			String fileName = name.substring(index+1);
			String fodlerPath = name.substring(0, index);
			return WorkspaceUtil.eapi(this.createFolder(fodlerPath)).createFile(fileName, stream);
		}
		return createFile(name, stream);
	}
	
	/**
	 * Creates a folder with the specified name.
	 */
	public IFolder createFolder(String name) {
		IFolder folder = container.getFolder(new Path(name));
		if (!folder.exists()) try {
			WorkspaceUtil.createResource(folder, progressMonitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		return folder;
	}
	
	/**
	 * Retrieve all files in the container.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class)</code></p>
	 */
	public List<IFile> getFiles() {
		return getFiles(null);
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	public List<IFile> getFiles(Predicate<IFile> fileConstraint) {
		return getResources(IFile.class, fileConstraint, null);
	}
	
	/**
	 * Retrieve all files in the container that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 * <p>Convenience method equal to <code>getResource(IFile.class, ...)</code></p>
	 */
	public List<IFile> getFiles(Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		return getResources(IFile.class, fileConstraint, contConstraint);
	}

	/**
	 * Retrieves the folder identified by the path of this container that
	 * is interpreted relative to this container's project.
	 * Returns {@code null} if path or folder does not exist.
	 */
	public IFolder getFolder() {
		IPath path = container.getProjectRelativePath();
		if (path == null)
			return null;
		IFolder folder = container.getFolder(path);
		return folder;
	}
	
	/**
	 * Retrieve all resources of the specified type.
	 * Only recurses through accessible sub-containers.
	 */
	public <T extends IResource> List<T> getResources(Class<T> clazz) {
		return getResources(container, clazz, null, null);
	}
	
	/**
	 * Retrieve all resources of the specified type that fulfill the specified
	 * resource-related constraint.
	 * Only recurses through accessible sub-containers.
	 */
	public <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<T> resConstraint) {
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
	public <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<T> resConstraint, Predicate<IContainer> contConstraint) {
		return getResources(container, clazz, resConstraint, contConstraint);
	}
	
	/*
	 * Private method to be used in a recursive manner.
	 */
	private <T extends IResource> List<T> getResources(IContainer container, Class<T> clazz, Predicate<T> resConstraint, Predicate<IContainer> contConstraint) {
		ArrayList<T> list = new ArrayList<>();
		if (container == null
				|| !container.exists()
				|| !container.isAccessible()
				|| contConstraint != null && !contConstraint.test(container)) {
			return list;
		}
		IResource[] members = null;
		try {
			members = container.members();
		} catch (CoreException e) {
			e.printStackTrace();
		}
		if (members != null) {
			for (Object member : members) {
				if (clazz.isAssignableFrom(member.getClass())) {
					@SuppressWarnings("unchecked")
					T resource = (T) member;
					if (resConstraint == null || resConstraint.test(resource)) {
						list.add(resource);
					}
				}
				if (member instanceof IContainer) {
					IContainer cont = (IContainer) member;
					list.addAll(getResources(cont, clazz, resConstraint, contConstraint));
				}
			}
		}
		return list;
	}
	
	public IContainerEAPI withProgressMonitor(IProgressMonitor monitor) {
		this.progressMonitor = monitor;
		return this;
	}
}