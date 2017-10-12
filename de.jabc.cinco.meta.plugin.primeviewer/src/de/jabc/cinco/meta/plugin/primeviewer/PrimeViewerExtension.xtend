package de.jabc.cinco.meta.plugin.primeviewer

import mgl.Node
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils

class PrimeViewerExtension extends GeneratorUtils{
	
	def primeFileExtension(Node it){
		var labelAnnot = retrievePrimeReference.annotations.filter[name == "pvFileExtension"]
		if (!labelAnnot.isNullOrEmpty) {
			labelAnnot.get(0).value.get(0)
			
		} else {
			primeTypeName
		}
	}
	
	
	def primeElementLabel(Node it) {
		var labelAnnot = retrievePrimeReference.annotations.filter[name == "pvLabel"]
		if (!labelAnnot.isNullOrEmpty) {
			var value = labelAnnot.get(0).value.get(0)
			'''eElement.eGet(eElement.eClass().getEStructuralFeature("«value»"))'''
		} else {
			'''"primeTypeName"'''
		}
	}
	
	
}