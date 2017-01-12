package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor

class ModelizerTemplate extends AbstractGratextTemplate {
	
	def generator() {
		fileFromTemplate(GratextGeneratorTemplate)
	}
	
	def nameFirstUpper(GraphModelDescriptor model) {
		model.name.toLowerCase.toFirstUpper
	}
		
	override template() '''	
		package «project.basePackage».generator
		
		import graphmodel.Edge
		import graphmodel.ModelElement
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelizer
		
		import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package
		import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Factory
		
		import «project.basePackage».*
		
		class «model.name»Modelizer extends GratextModelizer {
			
			new() {
				super(
					«model.nameFirstUpper»Factory.eINSTANCE,
					«model.nameFirstUpper»Package.eINSTANCE,
					«model.nameFirstUpper»Package.eINSTANCE.get«model.name»
				)
			}
			
			override createDiagram() {
				new «model.name»Diagram
			}
			
			override getBendpoints(Edge edge) {
				(edge as _Edge).route?.points?.map[p | p.x -> p.y]
			}
			
			override getDecoratorLocation(Edge edge, int index) {
				val loc = (edge as _Edge).decorations?.get(index)?.location
				if (loc != null) loc.x -> loc.y
			}
			
			override getIndex(ModelElement it) {
				placement.index
			}
			
			override setIndex(ModelElement element, int i) {
				val pm = (element as _Placed).placement
				if (pm != null)
					pm.index = i
			}
			
			override getWidth(ModelElement it) {
				placement.width
			}
			
			override getHeight(ModelElement it) {
				placement.height
			}
			
			override getX(ModelElement it) {
				placement.x
			}
			
			override getY(ModelElement it) {
				placement.y
			}
			
			def getPlacement(ModelElement element) {
				val orgPm = (element as _Placed).placement
				val newPm = «model.name»GratextFactory.eINSTANCE.create_Placement
				if (orgPm != null) {
					if (orgPm.x != 0) newPm.x = orgPm.x
					if (orgPm.y != 0) newPm.y = orgPm.y
					if (orgPm.width >= 0) newPm.width = orgPm.width
					if (orgPm.height >= 0) newPm.height = orgPm.height
					if (orgPm.index >= 0) newPm.index = orgPm.index
				}
				return newPm
			}
		}
	'''
}