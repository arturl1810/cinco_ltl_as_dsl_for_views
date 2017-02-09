package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.PrimitiveAttribute

abstract class Templateable {
	
	
	def CharSequence create(TemplateContainer tc);
	
	static def getType(Attribute attr) {
		switch attr {
			ComplexAttribute : attr.type.name
			PrimitiveAttribute : attr.type.getName
		}
	}
}