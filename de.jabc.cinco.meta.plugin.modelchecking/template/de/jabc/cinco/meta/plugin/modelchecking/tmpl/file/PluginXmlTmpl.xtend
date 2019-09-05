package de.jabc.cinco.meta.plugin.modelchecking.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class PluginXmlTmpl extends FileTemplate{
	
	override getTargetFileName() '''plugin.xml'''
	
	override template() '''
		<?xml version="1.0" encoding="UTF-8"?>
		<?eclipse version="3.4"?>
		<plugin>
		
		   <extension
		         point="de.jabc.cinco.meta.plugin.modelchecking.runtime.adapter">
		      <ModelCheckingAdapter
		            class="«basePackage».«model.name»ModelCheckingAdapter">
		      </ModelCheckingAdapter>
		   </extension>
		
		   		
		</plugin>
	'''
	
}
