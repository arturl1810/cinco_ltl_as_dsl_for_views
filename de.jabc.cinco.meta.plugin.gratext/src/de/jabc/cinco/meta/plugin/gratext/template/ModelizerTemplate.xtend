package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EFactory

class ModelizerTemplate extends AbstractGratextTemplate {
	
	def generator() {
		fileFromTemplate(GratextGeneratorTemplate)
	}
	
	def nameFirstUpper(GraphModelDescriptor model) {
		model.name.toLowerCase.toFirstUpper
	}
		
	override template() '''	
		package «project.basePackage».generator
		
		import graphmodel.IdentifiableElement
		import graphmodel.internal.InternalEdge
		import graphmodel.internal.InternalModelElement
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelizer
		
		import «project.basePackage».*
		
		class «model.name»Modelizer extends GratextModelizer {
			
			new() {
				super(
					switch «EPackage.name».Registry.INSTANCE.get("«graphmodel.nsURI»") {
						«EPackage.name» : («EPackage.name».Registry.INSTANCE.get("«graphmodel.nsURI»") as «EPackage.name»).EFactoryInstance
						«EFactory.name» : («EPackage.name».Registry.INSTANCE.get("«graphmodel.nsURI»") as «EFactory.name»)
					},
«««					«graphmodel.package».factory.«model.name»Factory.eINSTANCE,
					«graphmodel.package».«model.name.toLowerCase».internal.InternalPackage.eINSTANCE,
					«graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package.eINSTANCE.get«model.name»
				)
			}
			
			override createDiagram() {
				new «model.name»Diagram
			}
			
			override getBendpoints(InternalEdge edge) {
				(edge as _Edge).route?.points?.map[p | p.x -> p.y]
			}
			
			override getDecoratorLocation(InternalEdge edge, int index) {
				val loc = (edge as _Edge).decorations?.get(index)?.location
				if (loc != null) loc.x -> loc.y
			}
			
			override getIndex(IdentifiableElement it) {
				placement.index
			}
			
			override setIndex(IdentifiableElement element, int i) {
				val pm = (element as _Placed).placement
				if (pm != null)
					pm.index = i
			}
			
			override getWidth(InternalModelElement it) {
				placement.width
			}
			
			override getHeight(InternalModelElement it) {
				placement.height
			}
			
			override getX(InternalModelElement it) {
				placement.x
			}
			
			override getY(InternalModelElement it) {
				placement.y
			}
			
			def getPlacement(IdentifiableElement element) {
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