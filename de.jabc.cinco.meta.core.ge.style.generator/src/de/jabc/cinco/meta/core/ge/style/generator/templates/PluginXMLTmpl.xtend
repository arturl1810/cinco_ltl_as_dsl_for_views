package de.jabc.cinco.meta.core.ge.style.generator.templates

import java.util.ArrayList
import java.util.List
import mgl.GraphModel
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;

class PluginXMLTmpl extends GeneratorUtils {

	private String gmName
	private String pkgName
	private String icon
	private String fileExtension
	private String nsUri

	def generatePluginXML(GraphModel gm){
		gmName = gm.name
		pkgName = gm.packageName.toString
		icon = gm.iconPath
		fileExtension = gm.fileExtension
		this.nsUri = gm.nsURI
		return extensions
	}
	
	def List<CharSequence> extensions() {
		var List<CharSequence> exts = new ArrayList
		exts.addAll(
			diagramTypeProviders, 
			diagramTypes,
			editors,
			imageProvider,
			wizards,
			contentTypes,
			navigatorContent,
			popupMenus,
			referenceRegistry,
			perspectives,
			contentParser,
			factoryOverride
		);
		
		return exts
	}
	
	def getCode() '''
	«diagramTypeProviders»
	«diagramTypes»
	«editors»
	«imageProvider»
	«wizards»
	«contentTypes»
	«navigatorContent»
	«popupMenus»
	«referenceRegistry»
	«perspectives»
	'''
	
	def diagramTypeProviders() {
		diagramTypeProviders(pkgName, gmName)
	}
	
	def diagramTypeProviders(String pkgName, String gmName) '''
	<extension
		point="org.eclipse.graphiti.ui.diagramTypeProviders">
	<!--@CincoGen «gmName»-->
		<diagramTypeProvider
			class="«pkgName».«gmName»DiagramTypeProvider"
			description="This is the generated editor for the «gmName»"
			id="«pkgName».«gmName»DiagramTypeProvider"
			name=".«gmName» Diagram Editor">
			<diagramType
				id="«pkgName».«gmName»DiagramType">
			</diagramType>
			<imageProvider
				id="«pkgName».«gmName»ImageProvider">
			</imageProvider>
		</diagramTypeProvider>
	</extension>
	'''
	
	def diagramTypes() {
		diagramTypes(pkgName, gmName)
	}
	def diagramTypes(String pkgName, String gmName) '''
	<extension 
		point="org.eclipse.graphiti.ui.diagramTypes">
	<!--@CincoGen «gmName»-->
		<diagramType
			description="This is the generated diagram Type for «gmName»"
			id="«pkgName».«gmName»DiagramType"
			name="«gmName» Graphiti Diagram Type"
			type="«gmName»">
		</diagramType>
	</extension>
	'''
	
	def imageProvider() {
		imageProvider(pkgName, gmName)
	}
	
	def imageProvider(String pkgName, String gmName)'''
	<extension
		point="org.eclipse.graphiti.ui.imageProviders">
	<!--@CincoGen «gmName»-->
		<imageProvider
			class="«pkgName».«gmName»ImageProvider"
			id="«pkgName».«gmName»ImageProvider">
		</imageProvider>
	</extension>
	'''
	
	def wizards() {
		wizards(pkgName, gmName, icon)
	}
	
	def wizards(String pkgName, String gmName, String icon) '''
	<extension
		point="org.eclipse.ui.newWizards">
	<!--@CincoGen «gmName»-->
		<wizard
			category="de.jabc.cinco.meta.core.wizards.category.cinco"
			class="«pkgName».wizard.«gmName»DiagramWizard"
			«IF !icon.nullOrEmpty»
			icon="«icon»"
			«ENDIF»
			id="«pkgName».wizard.«gmName.toLowerCase»"
			name="New «gmName»">
		</wizard>
	</extension>
	'''
	
	def editors() {
		editors(pkgName, gmName, icon)
	}
	
	def editors(String pkgName, String gmName, String icon)'''
	<extension
		point="org.eclipse.ui.editors">
	<!--@CincoGen «gmName»-->
		<editor
			class="«pkgName».«gmName»DiagramEditor"
			contributorClass="org.eclipse.graphiti.ui.editor.DiagramEditorActionBarContributor"
			default="false"
			«IF !icon.nullOrEmpty»
			icon="«icon»"
			«ENDIF»
			id="«pkgName».«gmName»Editor"
			matchingStrategy="org.eclipse.graphiti.ui.editor.DiagramEditorMatchingStrategy"
			name="«gmName» Editor">
			<contentTypeBinding
				contentTypeId="«pkgName».«gmName»ContentType">
			</contentTypeBinding>
			<contentTypeBinding
				contentTypeId="org.eclipse.graphiti.content.diagram">
			</contentTypeBinding>
		</editor>
	</extension>
	'''
	
	def contentTypes() {
		contentTypes(pkgName, gmName, fileExtension)
	}
	
	def contentTypes(String pkgName, String gmName, String fileExtension) '''
	<extension
		point="org.eclipse.core.contenttype.contentTypes">
	<!--@CincoGen «gmName»-->
		<content-type
			file-extensions="«fileExtension»"
			id="«pkgName».«gmName»ContentType"
			name="«gmName» Content Type"
			priority="normal">
		</content-type>
	</extension>
	'''
	
	def popupMenus() {
		popupMenus(pkgName, gmName)
	}
	
	def popupMenus(String pkgName, String gmName) '''
«««	<extension
«««		point="org.eclipse.ui.popupMenus">
«««	<!--@CincoGen «gmName»-->
«««		<objectContribution
«««			adaptable="false"
«««			id="«pkgName».«gmName»ObjectContributor"
«««			nameFilter="*«gmName»"
«««			objectClass="org.eclipse.core.resources.IResource">
«««			<action
«««				class="«pkgName».graphiti.Create«gmName»Diagram"
«««				id="«pkgName».Create«gmName»DiagramAction"
«««				label="Create «gmName» Diagram">
«««			</action>
«««		</objectContribution>
«««	</extension>
	'''
	def perspectives() {
		perspectives(pkgName, gmName, icon)
	}
	
	def perspectives(String pkgName, String gmName, String icon)'''
	<extension
		point="org.eclipse.ui.perspectives">
	<!--@CincoGen «gmName»-->
		<perspective
			class="«pkgName».«gmName»PerspectiveFactory"
			fixed="false"
			id="«pkgName».«gmName.toLowerCase»perspective"
			«IF !icon.nullOrEmpty»
			icon="«icon»"
			«ENDIF»
			name="«gmName» Perspective">
		</perspective>
	</extension>
	'''
	
	def navigatorContent() {
		navigatorContent(pkgName, gmName)
	}
		
	def navigatorContent(String pkgName, String gmName)'''
	<extension
		point="org.eclipse.ui.navigator.navigatorContent">
	<!--@CincoGen «gmName»-->
		<commonWizard
			menuGroupId="mgl"
			type="new"
			wizardId="«pkgName».wizard.«gmName.toLowerCase»">
			<enablement></enablement>
		</commonWizard>
	</extension>
	'''
	
	def referenceRegistry() {
		referenceRegistry(pkgName, gmName)
	}
	
	def referenceRegistry(String pkgName, String gmName) '''
	<extension
		point="de.jabc.cinco.meta.core.referenceregistry">
	<!--@CincoGen «gmName»-->
		<FileExtensionsRegistry
			class="«pkgName».«gmName»FileExtensions">
		</FileExtensionsRegistry>
	</extension>
	'''
	
	def contentParser()  {
		contentParser(pkgName, gmName)
	}
	
	def contentParser(String pkgName, String gmName) '''
	<extension
	      point="org.eclipse.emf.ecore.content_parser">
	<!--@CincoGen «gmName»-->
	   <parser
	         class="«pkgName».«gmName»APIParser"
	         contentTypeIdentifier="«pkgName».«gmName»ContentType">
	   </parser>
	</extension>
	'''
	def factoryOverride() {
		factoryOverride(pkgName, gmName)
	}
	
	def factoryOverride(String pkgName, String gmName) '''
	<extension
		point="org.eclipse.emf.ecore.factory_override">
	<!--@CincoGen «gmName»-->
	   		<factory
	        	class="«pkgName».«gmName»Factory"
	        	uri="«nsUri»">
	   		</factory>
		</extension>
	'''
}