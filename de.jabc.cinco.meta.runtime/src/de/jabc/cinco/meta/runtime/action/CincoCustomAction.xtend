package de.jabc.cinco.meta.runtime.action

import graphmodel.IdentifiableElement
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass

abstract class CincoCustomAction<T extends IdentifiableElement> extends CincoRuntimeBaseClass {

	def getName() {
		class.name
	}
	
	def hasDoneChanges() {
		true
	}
	
    def canExecute(T element) {
    	true
    }
    
    def void execute(T element)
} 