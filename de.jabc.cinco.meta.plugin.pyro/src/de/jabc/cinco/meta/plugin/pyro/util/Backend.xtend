package de.jabc.cinco.meta.plugin.pyro.util

import mgl.ModelElement
import mgl.GraphModel
import mgl.Type

class Backend {
	def CharSequence fqn(Type me) {
		if(me instanceof GraphModel){
			return '''info.scce.pyro.«me.name»'''
		}
		if(me.eContainer instanceof ModelElement){
			return (me.eContainer as ModelElement).fqn			
		}
		throw new IllegalStateException("Unknown container")
	}
}