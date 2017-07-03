package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature

import graphmodel.ModelElement

abstract class CincoPostSelectHook<T extends ModelElement> {

	def abstract void postSelect(T modelElement)

}
