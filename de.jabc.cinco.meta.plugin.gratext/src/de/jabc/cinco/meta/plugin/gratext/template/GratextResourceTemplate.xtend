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
			
			private «modelizer.classSimpleName» modelGen
			
			override generateContent() {
				modelGen = new «modelizer.classSimpleName»
				modelGen.run(this)
			}
			
			override serialize() {
				new «serializer.classSimpleName»(this) {
					override sort(Iterable<InternalNode> nodes) {
						sortByInitialOrder(nodes)
					}
				}.run
			}
			
			def sortByInitialOrder(Iterable<InternalNode> nodes) {
				if (modelGen == null)
					nodes
				else nodes.sortWith[n1,n2 | 
					val i1 = modelGen.getInitialIndex(n1)
					val i2 = modelGen.getInitialIndex(n2)
					if (i1 < 0) {
						if (i2 < 0) 0 else 1
					} else if (i2 < 0) -1 else Integer.compare(i1,i2)
				]
			}
		}
	'''
}