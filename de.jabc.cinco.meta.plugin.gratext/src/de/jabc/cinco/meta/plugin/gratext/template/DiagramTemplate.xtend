package de.jabc.cinco.meta.plugin.gratext.template

class DiagramTemplate extends AbstractGratextTemplate {
	
override template()
'''	
package «project.basePackage»

import de.jabc.cinco.meta.plugin.gratext.runtime.resource.LazyDiagram

class «model.name»Diagram extends LazyDiagram {
	
	private Runnable initialization
	
	new(Runnable initialization) {
		super("«model.name»")
		this.initialization = initialization
	}
	
	override getDiagramTypeProviderId() {
		"«graphmodel.package».«model.name»DiagramTypeProvider"
	}
	
	override initialize() {
		initialization.run
	}
}
'''
}