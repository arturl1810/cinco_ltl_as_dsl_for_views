package de.jabc.cinco.meta.plugin.primeviewer.templates

import mgl.Node
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.core.utils.projects.ContentWriter

class PluginXMLTemplate {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	def static doGeneratePluginXMLContent(Iterable<Node> primeNodes, IProject p) {
		ContentWriter::writePluginXML(p, primeNodes.content, "")
	}
	
	def static getContent(Iterable<Node> primeNodes)'''
	<?xml version="1.0" encoding="UTF-8"?>
	<?eclipse version="3.4"?>
	<plugin>
	    «FOR n : primeNodes SEPARATOR '\n'»
	    «n.navigatorContent»
	    «ENDFOR»
	    <extension
	    	point="org.eclipse.ui.navigator.viewer">
	      	<viewerContentBinding
	        	viewerId="org.eclipse.ui.navigator.ProjectExplorer">
				<includes>
	         	«FOR n : primeNodes SEPARATOR '\n'»
	         		«n.extensionContent»
	         	«ENDFOR»
	        	</includes>
			</viewerContentBinding>
		</extension>
	
	</plugin>
	''' 
		
	def static getNavigatorContent(Node n) '''
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
	
	def static getExtensionContent(Node n) '''
		<contentExtension
			pattern="«n.graphModel.package».primeviewer.«n.primeTypePackagePrefix».«n.primeTypeName»ContentProvider">
		</contentExtension>
	'''
	
}