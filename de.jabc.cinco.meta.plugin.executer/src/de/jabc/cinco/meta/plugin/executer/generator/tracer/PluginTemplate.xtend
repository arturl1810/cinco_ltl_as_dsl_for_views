package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class PluginTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "plugin.xml"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<?eclipse version="3.4"?>
	<plugin>
	   <extension-point id="«graphmodel.tracerPackage»" name="Execution" schema="schema/«graphmodel.tracerPackage».exsd"/>
	   <extension-point id="«graphmodel.runnerPackage»" name="runner" schema="schema/«graphmodel.runnerPackage».exsd"/>
	
	   <extension
	         point="org.eclipse.ui.views">
	      <category
	            name="Execution Semantic"
	            id="«graphmodel.tracerPackage»">
	      </category>
	      <view
	            name="Tracer View"
	            category="«graphmodel.tracerPackage»"
	            class="«graphmodel.tracerPackage».views.View"
	            id="«graphmodel.tracerPackage».views.SampleView">
	      </view>
	   </extension>
	   <extension
	         point="org.eclipse.ui.perspectiveExtensions">
	      <perspectiveExtension
	            targetID="«graphmodel.graphModel.package».«graphmodel.graphModel.name.toLowerCase»toolperspective">
	         <view
	               ratio="0.5"
	               relative="de.jabc.cinco.meta.core.ui.propertyview"
	               relationship="right"
	               id="«graphmodel.tracerPackage».views.SampleView">
	         </view>
	      </perspectiveExtension>
	   </extension>
	   <extension
	         point="org.eclipse.help.contexts">
	      <contexts
	            file="contexts.xml">
	      </contexts>
	   </extension>
	
	</plugin>
	
	'''
	
}