package de.jabc.cinco.meta.plugin.gratext.template

class SerializerTemplate extends AbstractGratextTemplate {
		
	def fileExtension() {
		graphmodel.fileExtension
	}
			
	override template() '''
		package «project.basePackage».generator
		
		import graphmodel.GraphModel
		
		import org.eclipse.emf.ecore.resource.Resource
		import org.eclipse.graphiti.mm.pictograms.Diagram
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextSerializer
		
		class «model.name»Serializer extends GratextSerializer {
			
			new(Resource res) {
				super(res)
			}
			
			new(Diagram diagram, GraphModel model) {
				super(diagram, model)
			}
		}
	'''
}