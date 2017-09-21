package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.IdentifiableElement
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import graphmodel.internal.InternalPackage
import graphmodel.internal._Decoration
import graphmodel.internal._Point
import java.util.Collection
import java.util.List
import java.util.stream.Collectors
import java.util.stream.Stream
import java.util.stream.StreamSupport
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import graphmodel.ModelElement
import graphmodel.Type

abstract class GratextSerializer {

	static extension val ResourceExtension = new ResourceExtension

	InternalGraphModel model
	
	NonEmptyRegistry<InternalModelElementContainer,List<InternalNode>>
		nodesInitialOrder = new NonEmptyRegistry[InternalModelElementContainer c | c.allNodes.sort.toList]
			
	NonEmptyRegistry<InternalModelElementContainer,List<InternalNode>>
		nodesCurrentOrder = new NonEmptyRegistry[InternalModelElementContainer c | c.allNodes.sortBy[peIndex]]
	
	def getAllNodes(InternalModelElementContainer c) {
		c.modelElements.filter(InternalNode)
	}
	
	new (Resource res) {
		this(res.getContent(InternalGraphModel))
	}
	
	new (InternalGraphModel model) {
		this.model = model
	}
	
	def run() {
		template.toString
	}
	
	def template() {
		'''
		«model.name» «model.id» {
		  «model.attributes»
		  «model.containments»
		}
		'''
	}
	
	def String gratext(InternalNode node) {
		'''
		«node.name» «node.id» «node.placement» {
			«node.attributes»
			«node.containments»
			«node.edges»
		}
		''' 
	}
	
	def String gratext(InternalEdge edge) {
		'''
		-«edge.name»-> «edge.targetElement.internalElement.id» «edge.route» «edge.decorations» {
			id «if (edge.id.nullOrEmpty) edge.element.id else edge.id»
			«edge.attributes»
		}
		'''
	}
	
	def name(EObject obj) {
		obj.eClass.name.replaceFirst("Internal","")
	}
	
	def String attributes(EObject obj) {
		obj.eClass.attributes.gratext(obj)
	}
	
	def List<? extends EStructuralFeature> attributes(EClass cls) {
		switch cls.name {
			case "InternalGraphModel": #[]
			case "InternalContainer": #[]
			case "InternalNode": #[]
			case "InternalEdge": #[]
			case "InternalType": #[]
			case "GraphModel": #[]
			case "Container": #[]
			case "Node": #[]
			case "Edge": #[]
			case "Type": #[]
			default: combine(cls.getEAttributes, cls.getEReferences, cls.getESuperTypes.map[attributes].flatten)
		}
	}
	
	def <T> combine(Collection<? extends T> l1, Collection<? extends T> l2, Iterable<? extends T> l3) {
		Stream.concat(l1.stream, Stream.concat(l2.stream, StreamSupport.stream(l3.spliterator, false))).collect(Collectors.toList)
	}
	
	def containments(IdentifiableElement element) {
		switch element {
			InternalModelElementContainer: nodesInitialOrder.get(element).map[gratext].join('\n')
		}
	}
	
	def placement(InternalNode node) {
		'''at «node.x»,«node.y» size «node.width»,«node.height» «node.index»'''
	}
	
	def index(InternalNode node) {
		val org = nodesInitialOrder.get(node.container).indexOf(node)
		val now = nodesCurrentOrder.get(node.container).indexOf(node)
		if (org != now)
			'''index «now»'''
	}
	
	def peIndex(InternalNode node) {
		node.eContainer.eContents.indexOf(node)
	}
	
	def gratextIndex(InternalNode node) {
		node.container.modelElements.indexOf(node)
	}
	
	def sort(Iterable<InternalNode> nodes) {
		nodes
	}
	
	def route(InternalEdge edge) {
		val points = 
			if (!edge.bendpoints.empty)
				edge.bendpoints.map[gratext].join(' ')
				
		if (points != null)
			'''via «points»'''
	}
	
	def decorations(InternalEdge edge) {
			edge.decorators?.map[gratext].join(' ')
	}
	
	
	def gratext(_Point p) {
		'''(«p.x»,«p.y»)'''
	}
	
	def gratext(_Decoration dec) {
		'''decorate "«dec.nameHint»" at («dec.locationShift.x»,«dec.locationShift.y»)'''
	}
	
	def edges(InternalNode node) {
		node.getOutgoing(InternalEdge).map[gratext].join('\n')
	}
	
	def gratext(List<? extends EStructuralFeature> ftrs, EObject obj) {
		switch obj {
			InternalModelElement: ftrs.filter[featureID != InternalPackage.INTERNAL_MODEL_ELEMENT__ID]
			default: ftrs
		}.map[gratext(obj)].filterNull.join('\n')
	}
	
	def gratext(EStructuralFeature ftr, EObject obj) {
		val v = obj.eGet(ftr)
		if (v != null) {
			val value = switch v {
				List<?>: '[ ' + v.map[valueGratext].join(', ') + ' ]'
				default: v.valueGratext
			}
			if (value != null)
				ftr.name + ' ' + value
		}
	}
	
	def valueGratext(Object obj) {
		switch obj {
			ModelElement: obj?.internalElement?.id
			Type: obj?.internalElement.valueGratext
			InternalModelElement: obj?.id
			String: '"' + obj.replace("\\","\\\\").replace('"', '\\"').replace('\n', '\\n') + '"'
			EObject: '''
				«obj.name» {
						«obj.attributes»
					}''' 
			default: obj
		}
	}
	
}
		
