package de.jabc.cinco.meta.core.utils;

import java.io.ByteArrayInputStream;
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
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.PartInitException;

import de.jabc.cinco.meta.core.utils.eapi.IContainerEAPI;
import de.jabc.cinco.meta.core.utils.eapi.IFileEAPI;
import de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI;

public class WorkspaceUtil {

	/**
	 * Retrieve the API extension of the specified container that
	 * provides container-specific utility methods for convenience.
	 */
	public static IContainerEAPI eapi(IContainer container) {
		return new IContainerEAPI(container);
	}
	
	/**
	 * Retrieve the API extension of the specified file that
	 * provides file-specific utility methods for convenience.
	 */
	public static IFileEAPI eapi(IFile file) {
		return new IFileEAPI(file);
	}
	
	/**
	 * Retrieve the API extension of the specified resource that
	 * provides resource-specific utility methods for convenience.
	 */
	public static ResourceEAPI eapi(Resource resource) {
		return new ResourceEAPI(resource);
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
		return eapi(ResourcesPlugin.getWorkspace().getRoot()).getFiles(null);
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects).
	 */
	public static List<IFile> getFiles(Predicate<IFile> fileConstraint) {
		return eapi(ResourcesPlugin.getWorkspace().getRoot()).getFiles(fileConstraint, null);
	}
	
	/**
	 * Retrieve all files in the workspace that fulfill the specified
	 * file-related constraint.
	 * Only recurses through accessible sub-containers (e.g. open projects)
	 * that fulfill the specified container-related constraint.
	 */
	public static List<IFile> getFiles(Predicate<IFile> fileConstraint, Predicate<IContainer> contConstraint) {
		return eapi(ResourcesPlugin.getWorkspace().getRoot()).getFiles(fileConstraint, contConstraint);
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
		return eapi(ResourcesPlugin.getWorkspace().getRoot()).getResources(clazz, resConstraint, contConstraint);
	}
	
	/**
	 * Retrieves the resource for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist.
	 */
	public static IResource getResource(URI uri) {
		if (uri == null)
			return null;
		String path = uri.isPlatformResource()
				? uri.toPlatformString(true)
				: uri.path();
		return ResourcesPlugin.getWorkspace().getRoot().findMember(path);
	}
	
	/**
	 * Retrieves the resource for the specified object from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist.
	 */
	public static IResource getResource(EObject obj) {
		return getResource(EcoreUtil.getURI(obj));
	}
	
	/**
	 * Retrieves the file for the specified URI from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	public static IFile getFile(URI uri) {
		IResource res = getResource(uri);
		return (res instanceof IFile)
			? (IFile) res
			: null;
	}
	
	/**
	 * Retrieves the file for the specified EObject from the workspace,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or it is not a file.
	 */
	public static IFile getFile(EObject obj) {
		return getFile(EcoreUtil.getURI(obj));
	}
	
	/**
	 * Retrieves the underlying file for the specified EObject and opens
	 * it in a new editor in the active page of the active workbench window.
	 * @return 
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized 
	 */
	public static IEditorPart openEditor(EObject obj) throws PartInitException {
		IFile file = getFile(obj);
		if (file == null)
			return null;
		return eapi(file).openEditor();
	}
}
