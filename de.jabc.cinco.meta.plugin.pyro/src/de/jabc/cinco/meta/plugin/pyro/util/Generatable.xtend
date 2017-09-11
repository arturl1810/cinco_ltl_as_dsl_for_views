package de.jabc.cinco.meta.plugin.pyro.util

import de.jabc.cinco.meta.core.utils.MGLUtil
import mgl.Attribute

class Generatable {
	protected extension Escaper = new Escaper
	protected extension MGLExtension = new MGLExtension
	protected extension DyWAExtension = new DyWAExtension
	
	protected GeneratorCompound gc
	
	def getType(Attribute attr) {
		MGLUtil::getType(attr)
	}
	
	new(GeneratorCompound gc){
		this.gc = gc
	}
}