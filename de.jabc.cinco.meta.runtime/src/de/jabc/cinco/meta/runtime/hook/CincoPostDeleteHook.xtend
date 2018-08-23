package de.jabc.cinco.meta.runtime.hook

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.ModelElement

/**
 * @author Stefan Naujokat
 * 
 * Hook class that allows actions to be taken after a node, container, or edge has been deleted.
 * Please see {@link #getPostDeleteFunction(ModelElement)} to understand how this hook works.
 * 
 */
abstract class CincoPostDeleteHook<T extends ModelElement> extends CincoRuntimeBaseClass {
	
	/**
	 * This method will be called _before_ the given modelElement will be deleted, but the returned
	 * Runnable is called _after_. This means you can collect any information you require for your
	 * returned function. But beware that you must not access the modelElement directly, as it will
	 * be invalid when the returned function is called.
	 */
	def Runnable getPostDeleteFunction(T modelElement)

}
