package de.jabc.cinco.meta.plugin.gratext.template

class DiagramTemplate extends AbstractGratextTemplate {
	
	override template() '''	
		package «project.basePackage»
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.editor.LazyDiagram
		
		class «model.name»Diagram extends LazyDiagram {
			
			new() {
				super("«model.name»", "«graphmodel.package».editor.graphiti.«model.name»DiagramTypeProvider")
			}
		}
	'''
}