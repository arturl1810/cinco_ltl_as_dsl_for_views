package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class ModelCheckingAdditionalDataTmpl extends FileTemplate {

	override getTargetFileName() '''ModelCheckingAdditionalData.java'''
	
	override init(){
	}

	override template() '''
		package «package»;
		
		public interface ModelCheckingAdditionalData {
		
			boolean isDataEqual(Object o);
		}
		'''
}
