package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class TranslatorTmpl extends FileTemplate {

	override getTargetFileName() '''«model.name»Translator.xtend'''
	
	override init(){
	}

	override template() '''
		package «package»
		
		import info.scce.cinco.product.«model.name.toLowerCase».«model.name.toLowerCase».«model.name» 
		
		class «model.name»Translator {
		
			def getName() {
				return "Translate «model.name»"
			}
		
			def execute(«model.name» element) {
				graph = new ProgramGraph();
		
				graph
			}
		}
		'''
}
