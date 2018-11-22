package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class ResourceTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextResource.xtend'''
	
	override template() '''
		package «package»

		import graphmodel.internal.InternalGraphModel
		
		import de.jabc.cinco.meta.core.utils.registry.NonEmptyIdentityRegistry
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
		
		import «package».generator.«model.name»GratextTransformer
		
		class «model.name»GratextResource extends GratextResource {
			
			public static val transformers = new NonEmptyIdentityRegistry<InternalGraphModel,«model.name»GratextTransformer> [
				new «model.name»GratextTransformer
			]
			
			val lastTransformers = new NonEmptyIdentityRegistry<InternalGraphModel,«model.name»GratextTransformer> [
				new «model.name»GratextTransformer
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
		
			override isSortGratext() {
				«cpd?.annotations?.exists[name == "sortGratext"]»
			}
		}
	'''
	
}