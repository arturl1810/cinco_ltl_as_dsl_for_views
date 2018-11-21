package de.jabc.cinco.meta.runtime.provider

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.Type
import java.util.Map
import graphmodel.IdentifiableElement

/** 
 * This class returns a map with possible "display" strings for an attribute of type <A>
 * @author kopetzki
 * @param<E> The {@link ModelElement} type which contains the attribute
 * @param<A> The {@link ModelElement}'s attribute type
 */
abstract class CincoValuesProvider<E extends IdentifiableElement, A extends Object> extends CincoRuntimeBaseClass {
	
	/** 
	 * @param modelElement The {@link ModelElement} containing the attribute
	 * @return The mapping from mgl.Attribute to its display value i.e. maps from attribute type to {@link String}
	 */
	def Map<A, String> getPossibleValues(E modelElement)

}
