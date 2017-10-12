package de.jabc.cinco.meta.plugin.gratext.template

class GratextResourceTemplate extends AbstractGratextTemplate {
	
	def serializer() { fileFromTemplate(SerializerTemplate) }	
	def modelizer() { fileFromTemplate(ModelizerTemplate) }
		
	override template() '''
		package «project.basePackage»
		
		import graphmodel.internal.InternalNode
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
		import «serializer.className»
		import «modelizer.className»
		
		class «model.name»GratextResource extends GratextResource {
			
			override createModelizer() {
				new «modelizer.classSimpleName»
			}
			
			override createSerializer() {
				new «serializer.classSimpleName»(this) {
					override sort(Iterable<InternalNode> nodes) {
						sortByInitialOrder(nodes)
					}
				}
			}
			
			def sortByInitialOrder(Iterable<InternalNode> nodes) {
				if (modelizer == null)
					nodes
				else nodes.sortWith[n1,n2 | 
					val i1 = modelizer.getInitialIndex(n1)
					val i2 = modelizer.getInitialIndex(n2)
					if (i1 < 0) {
						if (i2 < 0) 0 else 1
					} else if (i2 < 0) -1 else Integer.compare(i1,i2)
				]
			}
		}
	'''
}