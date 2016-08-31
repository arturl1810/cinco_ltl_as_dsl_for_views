package de.jabc.cinco.meta.plugin.gratext.template

class GratextResourceTemplate extends AbstractGratextTemplate {
	
	def backupGenerator() { fileFromTemplate(BackupGeneratorTemplate) }	
	def modelGenerator() { fileFromTemplate(ModelGeneratorTemplate) }
		
	override template() '''
		package «project.basePackage»
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
		import «backupGenerator.className»
		import «modelGenerator.className»
		
		class «model.name»GratextResource extends GratextResource {
			
			override generateContent() {
				new «modelGenerator.classSimpleName»().doGenerate(this)
			}
			
			override serialize() {
				new «backupGenerator.classSimpleName»().toText(this)
			}
			
		}
	'''
}