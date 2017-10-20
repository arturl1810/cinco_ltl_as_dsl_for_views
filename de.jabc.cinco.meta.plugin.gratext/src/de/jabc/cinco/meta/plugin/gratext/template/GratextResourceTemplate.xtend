package de.jabc.cinco.meta.plugin.gratext.template

class GratextResourceTemplate extends AbstractGratextTemplate {
	
	def transformer() { fileFromTemplate(TransformerTemplate) }
		
	override template() '''
		package «project.basePackage»
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
		import «transformer.className»
		
		class «model.name»GratextResource extends GratextResource {
			
			override createTransformer() {
				new «transformer.classSimpleName»
			}
		}
	'''
}