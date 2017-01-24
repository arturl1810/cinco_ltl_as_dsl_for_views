package de.jabc.cinco.meta.core.mgl.model

import graphmodel.IdentifiableElement
import graphmodel.ModelElement

class GraphModelExtension {
	/**
	 * Checks whether to identifiable elements are equal by comparing their ids.
	 * 
	 * @param it the left hand side of the equals check.
	 * @param that the right hand side of the equals check.
	 * @return the result of the equals check.
	 */
	static def ==(IdentifiableElement it, IdentifiableElement that) { 
		(it === that) || (!(that === null) && id == that.id)
	}
	
	static def !=(IdentifiableElement it, IdentifiableElement that) { !(it == that) }
	
	/**
	 * Gets the path to root for any model element.
	 * 
	 * @param el the model element.
	 * @return the path to the root model element.
	 */
	static def Iterable<ModelElement> getPathToRoot(ModelElement el) {
		if (el.container != null && el.container instanceof ModelElement)
			#[el] + (el.container as ModelElement).pathToRoot
		else #[el]
	}
}