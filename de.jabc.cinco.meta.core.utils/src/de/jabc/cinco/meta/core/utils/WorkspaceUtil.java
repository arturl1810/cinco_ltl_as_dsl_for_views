package de.jabc.cinco.meta.core.utils;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;

public class WorkspaceUtil {

	/**
	 * Retrieve the API extension of the specified container that
	 * provides container-specific utility methods for convenience.
	 */
	public static IContainerEAPI resp(IContainer container) {
		return new IContainerEAPI(container);
	}
	
	/**
	 * Creates the specified resource.
	 * Recursively creates its parents as well, if not existent yet.
	 */
	public static <T extends IResource> T createResource(T resource, IProgressMonitor monitor) throws CoreException {
		if (resource == null || resource.exists())
			return resource;
		if (!resource.getParent().exists())
			createResource(resource.getParent(), monitor);
		switch (resource.getType()) {
		case IResource.FILE :
			((IFile) resource).create(new ByteArrayInputStream(new byte[0]), true, monitor);
			break;
		case IResource.FOLDER :
			((IFolder) resource).create(IResource.NONE, true, monitor);
			break;
		case IResource.PROJECT :
			((IProject) resource).create(monitor);
			((IProject) resource).open(monitor);
			break;
		}
		return resource;
	}

	/**
	 * Retrieve all files in the workspace.
	 * Only recurses through accessible containers (e.g. open projects).
	 */
	public static List<IFile> getFiles() {
		return resp(ResourcesPlugin.getWorkspace().getRoot()).getFiles(null);
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 */
	public static List<IFile> getFiles(Predicate<IFile> fileConstraint) {
		return resp(ResourcesPlugin.getWorkspace().getRoot()).getFiles(fileConstraint, null);
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 */
	public static List<IFile> getFiles(Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		return resp(ResourcesPlugin.getWorkspace().getRoot()).getFiles(fileConstraint, contConstraint);
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
	public static <T extends IResource> List<T> getResources(Class<T> clazz, Predicate<IContainer> contConstraint, Predicate<T> resConstraint) {
		return resp(ResourcesPlugin.getWorkspace().getRoot()).getResources(clazz, resConstraint, contConstraint);
	}
	
	
	/**
	 * Extension of the IContainer API
	 */
	public static class IContainerEAPI {
		
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
				final InputStream stream = new ByteArrayInputStream(content.getBytes(file.getCharset()));
				if (file.exists()) 
					file.setContents(stream, true, true, progressMonitor);
				else
					file.create(stream, true, progressMonitor);
				stream.close();
			}
			catch (final Exception e) {
				e.printStackTrace();
			}
			return file;
		}
		
		/**
		 * Creates a folder with the specified name.
		 */
		public IFolder createFolder(String name) {
			IFolder folder = container.getFolder(new Path(name));
			if (!folder.exists()) try {
				createResource(folder, progressMonitor);
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
}
