package de.jabc.cinco.meta.util.xapi

import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.ui.ide.IDE

/**
 * File-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class FileExtension {
	
	def URI getPlatformResourceURI(IFile file) {
		URI.createPlatformResourceURI(file.fullPath.toOSString, true)
	}
	
	def getResource(IFile file) {
		new ResourceSetImpl().getResource(file.platformResourceURI, true)
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained content of
	 * the specified type. It is assumed that one exists at the default index.
	 * However, if the content object at this index is not of appropriate type
	 * all content content objects are searched through and the first occurrence
	 * is returned, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(IFile file, Class<T> contentClass, int defaultIndex) {
		extension val ResourceExtension = new ResourceExtension
		file.resource.getContent(contentClass, defaultIndex)
	}
	
	/**
	 * Creates the resource for this file and retrieves the contained content of
	 * the specified type by searching through all content objects and returning the
	 * first occurrence, if existent.
	 * 
	 * @throws NoSuchElementException if the resource does not contain any content
	 *   of the specified type.
	 * @throws RuntimeException if accessing the resource failed.
	 */
	def <T extends EObject> T getContent(IFile file, Class<T> contentClass) {
		extension val ResourceExtension = new ResourceExtension
		file.resource.getContent(contentClass)
	}
	
	/**
	 * Retrieves the editor whose input is this file, if existent.
	 */
	def getEditor(IFile file) {
		extension val ext = new WorkbenchExtension
		getEditor[resource == file.resource]
	}
	
	/**
	 * Open a new editor for the specified file in the active page of the
	 * active workbench window.
	 * @return an open editor or {@code null} if an external editor was opened
	 *   or the containing resource is not associated with a file in the workspace.
	 * @throws PartInitException if the editor could not be initialized
	 */
	def openInEditor(IFile file) {
		extension val ext = new WorkbenchExtension
		IDE.openEditor(activePage, file)
	}
}
