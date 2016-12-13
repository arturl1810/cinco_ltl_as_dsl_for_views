package de.jabc.cinco.meta.core.utils.eapi

import graphmodel.ModelElement

import de.jabc.cinco.meta.core.utils.WorkbenchUtil
import de.jabc.cinco.meta.core.utils.WorkspaceUtil

import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.editor.DiagramEditor
import org.eclipse.ui.IEditorPart

/**
 * Entry point for Cinco-specific API extensions and utility methods.
 * 
 * @author Steve Bosselmann
 */
class Cinco {
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static ContainerEAPI eapi(IContainer container) {
		ContainerEAPI.eapi(container)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static FileEAPI eapi(IFile file) {
		FileEAPI.eapi(file)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static ResourceEAPI eapi(Resource resource) {
		ResourceEAPI.eapi(resource)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static EditorPartEAPI eapi(IEditorPart editor) {
		EditorPartEAPI.eapi(editor)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static DiagramEAPI eapi(Diagram diagram) {
		DiagramEAPI.eapi(diagram)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static ModelElementEAPI eapi(ModelElement element) {
		ModelElementEAPI.eapi(element)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static PictogramElementEAPI eapi(PictogramElement pe) {
		PictogramElementEAPI.eapi(pe)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static DiagramEditorEAPI eapi(DiagramEditor editor) {
		DiagramEditorEAPI.eapi(editor)
	}
	
	/**
	 * Retrieve the API extension of the specified object that
	 * provides specific utility methods for convenience.
	 */
	def static DiagramTypeProviderEAPI eapi(IDiagramTypeProvider dtp) {
		DiagramTypeProviderEAPI.eapi(dtp)
	}
	
	/**
 	 * Workbench-specifc utility methods. 
 	 */
	static class Workbench extends WorkbenchUtil { }


	/**
 	 * Workspace-specifc utility methods. 
 	 */
	static class Workspace extends WorkspaceUtil { }

}