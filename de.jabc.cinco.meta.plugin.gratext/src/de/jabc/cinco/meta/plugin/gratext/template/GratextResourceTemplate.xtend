package de.jabc.cinco.meta.plugin.gratext.template

class GratextResourceTemplate extends AbstractGratextTemplate {
	
	def transformer() { fileFromTemplate(TransformerTemplate) }
		
	override template() '''
		package «project.basePackage»
		
		import graphmodel.internal.InternalGraphModel
		
		import de.jabc.cinco.meta.core.utils.registry.NonEmptyIdentityRegistry
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource

		import «transformer.className»
		
		class «model.name»GratextResource extends GratextResource {
			
			public static val transformers = new NonEmptyIdentityRegistry<InternalGraphModel,«transformer.classSimpleName»> [
				new «transformer.classSimpleName»
			]
			
			val lastTransformers = new NonEmptyIdentityRegistry<InternalGraphModel,«transformer.classSimpleName»> [
				new «transformer.classSimpleName»
			]
		
			override getTransformer(InternalGraphModel model) {
				transformers.get(model)
			}
		
			override getLastTransformer(InternalGraphModel model) {
				lastTransformers.get(model)
			}
		
			override removeTransformer(InternalGraphModel model) {
				lastTransformers.put(model, transformers.remove(model))
			}
		}
	'''
}