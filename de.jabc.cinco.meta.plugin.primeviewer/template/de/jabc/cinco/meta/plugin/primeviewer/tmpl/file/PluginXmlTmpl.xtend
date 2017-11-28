package de.jabc.cinco.meta.plugin.primeviewer.tmpl.file

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node

class PluginXmlTmpl extends FileTemplate {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	override getTargetFileName() '''plugin.xml'''
	
	override template() '''
		<?xml version="1.0" encoding="UTF-8"?>
		<?eclipse version="3.0"?>
			
		<plugin>
			«FOR n : primeNodes SEPARATOR '\n'»
				«n.navigatorContent»
			«ENDFOR»
			<extension
				point="org.eclipse.ui.navigator.viewer">
				  <viewerContentBinding
					viewerId="org.eclipse.ui.navigator.ProjectExplorer">
					<includes>
					 «FOR n : primeNodes»
						 «n.extensionContent»
					 «ENDFOR»
					</includes>
				</viewerContentBinding>
			</extension>
		</plugin>
	''' 
	
	def getNavigatorContent(Node n) '''
		<extension
			point="org.eclipse.ui.navigator.navigatorContent">
			<navigatorContent
		    	activeByDefault="true"
		        contentProvider="«n.graphModel.package».primeviewer.«n.primeTypePackagePrefix».«n.primeTypeName»ContentProvider"
		        id="«n.graphModel.package».primeviewer.«n.primeTypePackagePrefix».«n.primeTypeName»ContentProvider"
		        labelProvider="«n.graphModel.package».primeviewer.«n.primeTypePackagePrefix».«n.primeTypeName»LabelProvider"
		        name="ExpandPrimesFor«n.graphModel.name»"
		        priority="highest">
		        <enablement>
		        	<instanceof
		            	value="org.eclipse.core.resources.IResource">
		            </instanceof>
				</enablement>
			</navigatorContent>
		</extension>
	'''
	
	def getExtensionContent(Node n) '''
		<contentExtension
			pattern="«n.graphModel.package».primeviewer.«n.primeTypePackagePrefix».«n.primeTypeName»ContentProvider">
		</contentExtension>
	'''
	
	def getPrimeNodes() {
		model.nodes.filter[primeReference?.hasAnnotation("pvFileExtension")]
	}
}
