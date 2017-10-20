package de.jabc.cinco.meta.core.ui.editor

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource

interface ResourceContributor {
	
	/**
	 * Adds content to the provided resource, if necessary.
	 */
	def Iterable<EObject> contributeToResource(Resource resource)
	
	/**
	 * Determines whether cross-reference solving is required for
	 * the specified content object.
	 */
	def boolean isResolveCrossReferencesRequired(EObject obj)
	
}
