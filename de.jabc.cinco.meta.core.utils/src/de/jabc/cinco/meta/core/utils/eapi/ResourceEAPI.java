package de.jabc.cinco.meta.core.utils.eapi;

import graphmodel.GraphModel;

import java.util.NoSuchElementException;
import java.util.Optional;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.graphiti.mm.pictograms.Diagram;

import de.jabc.cinco.meta.core.utils.WorkspaceUtil;

/**
 * Extension of the Resource API
 */
public class ResourceEAPI {
	
	private Resource resource;
	private IProgressMonitor progressMonitor;

	public ResourceEAPI(Resource resource) {
		this.resource = resource;
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
	public Diagram getDiagram() {
		return getContent(Diagram.class, 0);
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
	public GraphModel getGraphModel() {
		return getContent(GraphModel.class, 1);
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
	public <T extends GraphModel> T getGraphModel(Class<T> modelClass) {
		return getContent(modelClass, 1);
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
	public <T extends EObject> T getContent(Class<T> contentClass, int defaultIndex) {
		try {
			EList<EObject> objs = resource.getContents();
			if (defaultIndex >= 0 && defaultIndex < objs.size()) {
				EObject obj = objs.get(defaultIndex);
				if (contentClass.isAssignableFrom(obj.getClass())) {
					@SuppressWarnings("unchecked")
					T retVal = (T) obj;
					return (T) retVal;
				}
			}
			return getContent(contentClass);
		} catch(RuntimeException re) {
			throw re;
		} catch(Exception e) {
			e.printStackTrace();
			throw new RuntimeException(
				"Failed to retrieve resource content for file: " + resource, e);
		}
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
	public <T extends EObject> T getContent(Class<T> contentClass) {
		try {
			Optional<T> opt = resource.getContents().stream()
				.filter(c -> contentClass.isAssignableFrom(c.getClass()))
				.map(contentClass::cast)
				.findFirst();
			if (opt.isPresent())
				return opt.get();
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
	
	public ResourceEAPI withProgressMonitor(IProgressMonitor monitor) {
		this.progressMonitor = monitor;
		return this;
	}
			
	/**
	 * Retrieves the IResource pendant for the specified resource,
	 * if existent. Returns {@code null} if the resource does not exist
	 * or the specified URI is not a platform URI.
	 */
	public IResource getIResource() {
		return WorkspaceUtil.getResource(resource.getURI());
	}
	
	/**
	 * Retrieves the file for this resource, if existent.
	 * Returns {@code null} if the file does not exist.
	 */
	public IFile getFile() {
		IResource res = getIResource();
		return (res instanceof IFile)
			? (IFile) res
			: null;
	}

	/**
	 * Retrieves the project this resource is located in, if existent.
	 * Returns {@code null} if the resource or the project does not exist.
	 */
	public IProject getProject() {
		IResource ires = getIResource();
		if (ires == null)
			return null;
		return ires.getProject();
	}
}