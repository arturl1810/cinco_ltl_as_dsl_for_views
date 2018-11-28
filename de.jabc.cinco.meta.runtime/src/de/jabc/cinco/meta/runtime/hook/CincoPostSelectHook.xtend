package de.jabc.cinco.meta.runtime.hook

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.ModelElement

abstract class CincoPostSelectHook<T extends ModelElement> extends CincoRuntimeBaseClass {

	def abstract void postSelect(T modelElement)

}