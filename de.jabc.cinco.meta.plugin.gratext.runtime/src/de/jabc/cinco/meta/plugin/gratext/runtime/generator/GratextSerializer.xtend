package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.Edge
import graphmodel.GraphModel
import graphmodel.GraphmodelPackage
import graphmodel.ModelElement
import graphmodel.Node
import graphmodel.ModelElementContainer
import graphmodel.IdentifiableElement

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

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.getDiagram
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.getGraphModel

abstract class GratextSerializer {

	NonEmptyRegistry<ModelElement,PictogramElement>
		peCache = new NonEmptyRegistry[linkService.getPictogramElements(diagram, it).get(0)]
			
	NonEmptyRegistry<ModelElementContainer,List<Node>>
		nodesInitialOrder = new NonEmptyRegistry[ModelElementContainer c | c.allNodes.sort]
			
	NonEmptyRegistry<ModelElementContainer,List<Node>>
		nodesCurrentOrder = new NonEmptyRegistry[ModelElementContainer c | c.allNodes.sortBy[peIndex]]
	
	Diagram diagram
	GraphModel model
	
	new (Resource res) {
		this(res.diagram, res.graphModel)
	}
	
	new (Diagram diagram, GraphModel model) {
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
	
	def String gratext(Node node) {
		'''
		«node.name» «node.id» «node.placement» {
			«node.attributes»
			«node.containments»
			«node.edges»
		}
		''' 
	}
	
	def String gratext(Edge edge) {
		'''
		-«edge.name»-> «edge.targetElement.id» «edge.pe.route» «edge.pe.decorations» {
			id «edge.id»
			«edge.attributes»
		}
		'''
	}
	
	def name(EObject obj) {
		obj.eClass.name
	}
	
	def String attributes(EObject obj) {
		obj.eClass.attributes.gratext(obj)
	}
	
	def List<? extends EStructuralFeature> attributes(EClass cls) {
		switch cls.name {
			case "GraphModel": new ArrayList
			case "Container": new ArrayList
			case "Node": new ArrayList
			case "Edge": new ArrayList
			default: combine(cls.getEAttributes, cls.getEReferences, cls.getESuperTypes.map[attributes].flatten)
		}
	}
	
	def <T> combine(Collection<? extends T> l1, Collection<? extends T> l2, Iterable<? extends T> l3) {
		Stream.concat(l1.stream, Stream.concat(l2.stream, StreamSupport.stream(l3.spliterator, false))).collect(Collectors.toList)
	}
	
	def containments(IdentifiableElement element) {
		switch element {
			ModelElementContainer: nodesInitialOrder.get(element).map[gratext].join('\n')
		}
	}
	
	def placement(Node node) {
		val ga = node.pe.graphicsAlgorithm
		'''at «ga.x»,«ga.y» size «ga.width»,«ga.height» «node.index»'''
	}
	
	def index(Node node) {
		val org = nodesInitialOrder.get(node.container).indexOf(node)
		val now = nodesCurrentOrder.get(node.container).indexOf(node)
		if (org != now)
			'''index «now»'''
	}
	
	def peIndex(Node node) {
		node.pe.eContainer.eContents.indexOf(node.pe)
	}
	
	def gratextIndex(Node node) {
		node.container.allNodes.indexOf(node)
	}
	
	def sort(List<Node> nodes) {
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
	
	def edges(Node node) {
		node.outgoing.map[gratext].join('\n')
	}
	
	def gratext(List<? extends EStructuralFeature> ftrs, EObject obj) {
		switch obj {
			ModelElement: ftrs.filter[it.featureID != GraphmodelPackage.MODEL_ELEMENT__ID]
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
			ModelElement: obj?.id
			String: '"' + obj.replace("\\","\\\\").replace('"', '\\"').replace('\n', '\\n') + '"'
			EObject: '''
				«obj.name» {
						«obj.attributes»
					}''' 
			default: obj
		}
	}
	
}
		