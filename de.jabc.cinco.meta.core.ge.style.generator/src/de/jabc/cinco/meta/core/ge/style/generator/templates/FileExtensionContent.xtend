package de.jabc.cinco.meta.core.ge.style.generator.templates

import java.util.List
import java.util.Arrays
import de.jabc.cinco.meta.core.referenceregistry.implementing.IFileExtensionSupplier
import mgl.GraphModel
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;

class FileExtensionContent extends GeneratorUtils{
	
	var gm = null as GraphModel
	var exts = null as List<String>
	
	new (GraphModel graphmodel, List<String> fileExtensions) {
		exts = fileExtensions
		gm = graphmodel
	}
	
	def generateJavaClassContents(GraphModel gm) '''
	package «gm.packageName»;
	
	public class «gm.fuName.toFirstUpper»FileExtensions implements «IFileExtensionSupplier.name» {
		
		@Override
		public «List.name»<«String.name»> getKnownFileExtensions() {
			return «Arrays.name».asList(new «String.name»[] {«FOR e : exts SEPARATOR ','» "«e»"«ENDFOR »});
		}
	}
	'''

	def generatePluginExtensionContents() '''
	<extension
		point="de.jabc.cinco.meta.core.referenceregistry">
	<!--@CincoGen «gm.fuName.toFirstUpper»-->
		<FileExtensionsRegistry
			class="«gm.packageName».«gm.fuName.toFirstUpper»FileExtensions">
		</FileExtensionsRegistry>
	</extension>
	'''
	
}