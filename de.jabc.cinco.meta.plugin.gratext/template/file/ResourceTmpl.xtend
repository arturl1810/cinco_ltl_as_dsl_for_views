package file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class ResourceTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextResource.xtend'''
	
	override template() '''
		package «package»
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
		import «package».generator.«model.name»GratextTransformer
		
		class «model.name»GratextResource extends GratextResource {
			
			override createTransformer() {
				new «model.name»GratextTransformer
			}
		}
	'''
	
}