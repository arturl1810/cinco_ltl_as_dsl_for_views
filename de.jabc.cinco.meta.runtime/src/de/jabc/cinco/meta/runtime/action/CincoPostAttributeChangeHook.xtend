package de.jabc.cinco.meta.runtime.action

import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import org.eclipse.emf.ecore.EStructuralFeature

abstract class CincoPostAttributeChangeHook<T extends EObject> extends CincoRuntimeBaseClass {
	
	def getName() {
    	class.name
    }
	
	def boolean canHandleChange(T modelElement, EStructuralFeature changedAttribute);
	def void handleChange(T modelElement, EStructuralFeature changedAttribute);
}