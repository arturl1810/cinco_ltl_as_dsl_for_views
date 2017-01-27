package de.jabc.cinco.meta.runtime.xapi

import graphmodel.IdentifiableElement
import graphmodel.ModelElement

/**
 * Workbench-specific extension methods.
 * 
 * @author Johannes Neubauer
 */
class GraphModelExtension {
	/**
	 * Checks whether to identifiable elements are equal by comparing their ids.
	 * 
	 * @param it the left hand side of the equals check.
	 * @param that the right hand side of the equals check.
	 * @return the result of the equals check.
	 */
	def ==(IdentifiableElement it, IdentifiableElement that) { 
		(it === that) || (!(that === null) && id == that.id)
	}
	
	def !=(IdentifiableElement it, IdentifiableElement that) { !(it == that) }
	
	/**
	 * Gets the path to root for any model element.
	 * 
	 * @param el the model element.
	 * @return the path to the root model element.
	 */
	def Iterable<ModelElement> getPathToRoot(ModelElement el) {
		if (el.container != null && el.container instanceof ModelElement)
			#[el] + (el.container as ModelElement).pathToRoot
		else #[el]
	}
}
