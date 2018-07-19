package de.jabc.cinco.meta.util.xapi

import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.ui.ide.IDE
import java.util.jar.JarFile
import org.apache.commons.io.FilenameUtils
import java.util.jar.JarEntry
import org.eclipse.ui.IEditorPart

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
		getResource(file.platformResourceURI)
	}
	
	def getResource(URI uri) {
		new ResourceSetImpl().getResource(uri, true)
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
	
	/**
	 * Does nothing if no file extension has been provided.
	 * 
	 * @param fileExtensions  Must not be {@code null} or empty.
	 */
	def findFiles(JarFile archive, String... fileExtensions) {
		extension val ext = new CollectionExtension
		archive.entries.toList.filter[
			val fe = FilenameUtils.getExtension(it.toString)
			!fileExtensions?.filter[equalsIgnoreCase(fe)].isEmpty
		].map[archive.getURI(it)]
	}
	
	/**
	 * Creates an URI for an entry in an archive.
	 * 
	 * @param archive  The archive. Must not be {@code null}.
	 * @param entry  The entry. Must not be {@code null}.
	 * 
	 * @return  The URI in the form {@code jar:file:/path/to/archive.jar!/path/to/file}
	 */
	def getURI(JarFile archive, JarEntry entry) {
		URI.createURI("jar:file:" + archive.name + "!/" + entry)
	}
}
