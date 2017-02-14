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
import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.stream.Collectors
import java.util.stream.Stream
import java.util.stream.StreamSupport
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement

import static org.eclipse.graphiti.ui.services.GraphitiUi.getLinkService

abstract class GratextSerializer {

	static extension val ResourceExtension = new ResourceExtension

	NonEmptyRegistry<InternalModelElement,PictogramElement>
		peCache = new NonEmptyRegistry[linkService.getPictogramElements(diagram, it).get(0)]
			
	NonEmptyRegistry<InternalModelElementContainer,List<InternalNode>>
		nodesInitialOrder = new NonEmptyRegistry[InternalModelElementContainer c | c.allNodes.sort.toList]
			
	NonEmptyRegistry<InternalModelElementContainer,List<InternalNode>>
		nodesCurrentOrder = new NonEmptyRegistry[InternalModelElementContainer c | c.allNodes.sortBy[peIndex]]
	
	def getAllNodes(InternalModelElementContainer c) {
		c.modelElements.filter(InternalNode)
	}
	
	Diagram diagram
	InternalGraphModel model
	
	new (Resource res) {
		this(res.diagram, res.getContent(InternalGraphModel))
	}
	
	new (Diagram diagram, InternalGraphModel model) {
		this.diagram = diagram
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
		-«edge.name»-> «edge.targetElement.internalElement.id» «edge.pe.route» «edge.pe.decorations» {
			id «edge.id»
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
			case "InternalGraphModel": new ArrayList
			case "InternalContainer": new ArrayList
			case "InternalNode": new ArrayList
			case "InternalEdge": new ArrayList
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
		val ga = node.pe.graphicsAlgorithm
		'''at «ga.x»,«ga.y» size «ga.width»,«ga.height» «node.index»'''
	}
	
	def index(InternalNode node) {
		val org = nodesInitialOrder.get(node.container).indexOf(node)
		val now = nodesCurrentOrder.get(node.container).indexOf(node)
		if (org != now)
			'''index «now»'''
	}
	
	def peIndex(InternalNode node) {
		node.pe.eContainer.eContents.indexOf(node.pe)
	}
	
	def gratextIndex(InternalNode node) {
		node.container.modelElements.indexOf(node)
	}
	
	def sort(Iterable<InternalNode> nodes) {
		nodes
	}
	
	def route(PictogramElement pe) {
		val points = switch pe {
			FreeFormConnection case !pe.bendpoints.empty:
				pe.bendpoints.map[gratext].join(' ')
		}
		if (points != null)
			'''via «points»'''
	}
	
	def decorations(PictogramElement pe) {
		switch pe {
			Connection case !pe.connectionDecorators.empty:
				pe.connectionDecorators.map[gratext].join(' ')
		}
	}
	
	def pe(EObject obj) {
		peCache.get(obj)
	}
	
	def gratext(Point p) {
		'''(«p.x»,«p.y»)'''
	}
	
	def gratext(ConnectionDecorator dec) {
		val ga = dec.graphicsAlgorithm
		'''decorate "«ga.name»" at («ga.x»,«ga.y»)'''
	}
	
	def edges(InternalNode node) {
		node.getOutgoing(InternalEdge).map[gratext].join('\n')
	}
	
	def gratext(List<? extends EStructuralFeature> ftrs, EObject obj) {
		switch obj {
			InternalModelElement: ftrs.filter[it.featureID != InternalPackage.INTERNAL_MODEL_ELEMENT__ID]
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
		
