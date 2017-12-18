package de.jabc.cinco.meta.runtime.hook

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.GraphModel

abstract class CincoPostSaveHook<T extends GraphModel> extends CincoRuntimeBaseClass {

	def abstract void postSave(T object)

}
