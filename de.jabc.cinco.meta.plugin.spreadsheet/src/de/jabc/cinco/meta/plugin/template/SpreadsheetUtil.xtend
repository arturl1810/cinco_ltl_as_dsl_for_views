package de.jabc.cinco.meta.plugin.template

import mgl.Attribute
import mgl.ComplexAttribute
import mgl.PrimitiveAttribute

class SpreadsheetUtil {
	
	static def getType(Attribute attr) {
	 	switch attr {
	 		ComplexAttribute : attr.type.name
	 		PrimitiveAttribute : attr.type.getName
	 	}
	 }
	
}