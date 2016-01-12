package de.jabc.cinco.meta.core.ge.generator.templates

import mgl.GraphModel
import java.util.List
import java.util.Arrays
import de.jabc.cinco.meta.core.referenceregistry.implementing.IFileExtensionSupplier
import de.metaframe.jabc.editor.menu.SeperatedGroup

class FileExtensionContent {
	
	var packageName = ""
	var graphModel = null as GraphModel
	var exts = null as List<String>
	
	new (GraphModel gm, List<String> fileExtensions) {
		packageName = gm.package
		packageName += ".graphiti"
		graphModel = gm as GraphModel
		exts = fileExtensions
	}
	
	def generateJavaClassContents() '''
	package «packageName»;
	
	public class «graphModel.name.toFirstUpper»FileExtensions implements «IFileExtensionSupplier.name» {
		
		@Override
		public «List.name»<«String.name»> getKnownFileExtensions() {
			return «Arrays.name».asList(new «String.name»[] {«FOR e : exts SEPARATOR ','» "«e»"«ENDFOR »});
		}
		
	}
	'''

	def generatePluginExtensionContents() '''
	<extension
		point="de.jabc.cinco.meta.core.referenceregistry">
	<!--@CincoGen «graphModel.name.toFirstUpper»-->
		<FileExtensionsRegistry
			class="«packageName».«graphModel.name.toFirstUpper»FileExtensions">
		</FileExtensionsRegistry>
	</extension>
	'''
	
}