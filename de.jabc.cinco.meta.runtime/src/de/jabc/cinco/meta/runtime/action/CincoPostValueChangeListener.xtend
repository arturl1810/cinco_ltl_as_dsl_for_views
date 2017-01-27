package de.jabc.cinco.meta.runtime.action

import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass

abstract class CincoPostValueChangeListener<T extends EObject> extends CincoRuntimeBaseClass {
	
	def getName() {
    	class.name
    }
	
	def boolean canHandleChange(T modelElement);
	def void handleChange(T modelElement);
}