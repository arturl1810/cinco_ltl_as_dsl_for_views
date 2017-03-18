package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor
import org.eclipse.emf.ecore.EPackage

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
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.DiagramBuilder
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelTransformer
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.ModelBuilder
		
		import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package
		import «graphmodel.package».«model.name.toLowerCase».internal.InternalPackage
		import «project.basePackage».*
		
		import org.eclipse.emf.ecore.resource.Resource
		import org.eclipse.emf.ecore.EPackage
		
		
		class «model.name»Modelizer extends ModelBuilder {
		
			new() {
				super(new GratextModelTransformer(
					EPackage.Registry.INSTANCE.getEFactory("«graphmodel.nsURI»"),
					InternalPackage.eINSTANCE,
					«model.nameFirstUpper»Package.eINSTANCE.get«model.name»
				))
			}
		
			override run(Resource resource) {
				super.run(resource)
				new DiagramBuilder(new «model.name»Diagram, model) {
		
					override getBendpoints(InternalEdge it) {
						(counterpart as _Edge)?.route?.points?.map[x -> y]
					}
		
					override getDecoratorLocation(InternalEdge it, int index) {
						val loc = (counterpart as _Edge)?.decorations?.get(index)?.location
						if (loc != null)
							loc.x -> loc.y
					}
		
					override getIndex(IdentifiableElement it) {
						counterpart.placement.index
					}
		
					override setIndex(IdentifiableElement it, int i) {
						counterpart.placement.setIndex(i)
					}
		
					override getX(InternalModelElement it) {
						counterpart.placement.x
					}
		
					override getY(InternalModelElement it) {
						counterpart.placement.y
					}
		
					override getWidth(InternalModelElement it) {
						counterpart.placement.width
					}
		
					override getHeight(InternalModelElement it) {
						counterpart.placement.height
					}
					
				}.build(resource)
			}
			
			/* Maps model elements on Gratext model elements and vice versa.
			 * Used to retrieve the location-specific attributes of a model
			 * element that have been saved in Gratext.
			 *
			 * Should be replaced with the legendary new API methods
			 */
			def getCounterpart(IdentifiableElement elm) {
				transformer.getCounterpart(elm)
			}
			
			override getIndex(IdentifiableElement element) {
				element.placement.index
			}
			
			override setIndex(IdentifiableElement element, int i) {
				element.placement.index = i
			}
			
			def getPlacement(IdentifiableElement elm) {
				val newPm = «model.name»GratextFactory.eINSTANCE.create_Placement
				if (elm instanceof _Placed) {
					val orgPm = elm.placement
					if (orgPm != null) {
						if(orgPm.x != 0) newPm.x = orgPm.x
						if(orgPm.y != 0) newPm.y = orgPm.y
						if(orgPm.width >= 0) newPm.width = orgPm.width
						if(orgPm.height >= 0) newPm.height = orgPm.height
						if(orgPm.index >= 0) newPm.index = orgPm.index
					}
				}
				return newPm
			}
		}
	'''
		
	def template_old() '''	
		package «project.basePackage».generator
		
		import graphmodel.IdentifiableElement
		import graphmodel.internal.InternalEdge
		import graphmodel.internal.InternalModelElement
		
		import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelizer
		
		import «project.basePackage».*
		
		class «model.name»Modelizer extends GratextModelizer {
			
			new() {
				super(
					«EPackage.name».Registry.INSTANCE.getEFactory("«graphmodel.nsURI»"),
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