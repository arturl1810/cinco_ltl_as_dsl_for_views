package de.jabc.cinco.meta.runtime.hook

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import org.eclipse.emf.ecore.EObject

abstract class CincoPreDeleteHook<T extends EObject> extends CincoRuntimeBaseClass {
	
	def void preDelete(T modelElement)
}
