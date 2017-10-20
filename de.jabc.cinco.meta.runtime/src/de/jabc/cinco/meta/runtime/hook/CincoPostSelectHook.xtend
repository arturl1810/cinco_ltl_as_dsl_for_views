package de.jabc.cinco.meta.runtime.hook

import graphmodel.ModelElement

abstract class CincoPostSelectHook<T extends ModelElement> {

	def abstract void postSelect(T modelElement)

}