package de.jabc.cinco.meta.runtime.xapi

import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import org.eclipse.emf.ecore.util.EcoreUtil

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
	
	def InternalModelElementContainer getCommonContainer(InternalModelElementContainer ce, InternalEdge e) {
		var source = e.get_sourceElement();
		var target = e.get_targetElement();
		if (EcoreUtil.isAncestor(ce, source) && EcoreUtil.isAncestor(ce, target)) {
			for (InternalModelElement c : ce.getModelElements()) {
				if (c instanceof InternalModelElementContainer) {
					if (EcoreUtil.isAncestor(c, source) && EcoreUtil.isAncestor(c, target)) {
						return c.getCommonContainer(e);
					}
				}
			}
		} else if (ce instanceof InternalModelElement) {
			return ce.container.getCommonContainer(e);
		}
		return ce;
	}
}
