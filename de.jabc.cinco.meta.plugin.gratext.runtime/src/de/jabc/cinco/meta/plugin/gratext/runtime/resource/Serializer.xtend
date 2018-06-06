package de.jabc.cinco.meta.plugin.gratext.runtime.resource

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
import graphmodel.IdentifiableElement
import graphmodel.ModelElement
import graphmodel.Node
import graphmodel.Type
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalIdentifiableElement
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

import static extension org.eclipse.emf.ecore.util.EcoreUtil.getID
import java.text.SimpleDateFormat
import java.util.Date

class Serializer {

	val nodesSerializationOrder = new NonEmptyRegistry[InternalModelElementContainer it | allNodes.sortBy[orderIndex]]
		
	val nodesLayerOrder = new NonEmptyRegistry[InternalModelElementContainer it | allNodes.sortBy[layer]]

	InternalGraphModel model
	GratextResource resource
	Transformer transformer
	
	def getAllNodes(InternalModelElementContainer c) {
		c.modelElements.filter(InternalNode)
	}
	
	new (GratextResource resource, InternalGraphModel model, Transformer transformer) {
		this.resource = resource
		this.model = model
		this.transformer = transformer
	}
	
	def String run() {
		template.toString
	}
	
	def template() {
		'''
		«model.name» «model.nonInternalID» {
		  «model.attributes»
		  «model.containments»
		}
		'''
	}
	
	def String toGratext(InternalNode node) {
		'''
		«node.name» «node.nonInternalID» «node.placement» {
			«node.attributes»
			«node.containments»
			«node.edges»
		}
		''' 
	}
	
	def String toGratext(InternalEdge edge) {
		'''
		-«edge.name»-> «edge.targetElement.id» «edge.route» «edge.decorations» {
			id «edge.nonInternalID»
			«edge.attributes»
		}
		'''
	}
	
	def placement(InternalNode node) {
		'''at «node.x»,«node.y» size «node.width»,«node.height»«node.index»'''
	}
	
	def index(InternalNode node) {
		val layerIndex = node.layerIndex
		if (node.serializationIndex != layerIndex)
			''' index «layerIndex»'''
	}
	
	def name(EObject obj) {
		obj.eClass.name.replaceFirst("Internal","")
	}
	
	def String attributes(EObject obj) {
		obj.eClass.attributes.toGratext(obj)
	}
	
	def Iterable<EStructuralFeature> attributes(EClass it) {
		if (InternalPackage.eINSTANCE.getEClassifiers.contains(it))
			#[]
		else (
			getEAttributes
			+ getEReferences
			+ getESuperTypes.map[attributes].flatten
		).filter[!name?.startsWith("gratext_")]
	}
	
	def <T> combine(Collection<? extends T> l1, Collection<? extends T> l2, Iterable<? extends T> l3) {
		Stream.concat(l1.stream, Stream.concat(l2.stream, StreamSupport.stream(l3.spliterator, false))).collect(Collectors.toList)
	}
	
	def getContainments(InternalIdentifiableElement it) {
		switch it {
			InternalModelElementContainer: nodesSerializationOrder.get(it).map[toGratext].join('\n')
		}
	}
	
	def getInitialIndex(InternalNode node) {
		transformer.getInitialIndex(node)
	}
	
	def getSerializationIndex(InternalNode node) {
		nodesSerializationOrder.get(node.container).indexOf(node)
	}
	
	def getLayerIndex(InternalNode node) {
		nodesLayerOrder.get(node.container).indexOf(node)
	}
	
	def getOrderIndex(InternalNode node) {
		val index = node.initialIndex
		if (index < 0)
			node.layer
		else index
	}
	
	def getLayer(InternalNode node) {
		(node.element as Node).layer
	}
	
	def route(InternalEdge edge) {
		val points = 
			if (!edge.bendpoints.empty)
				edge.bendpoints.map[toGratext].join(' ')
				
		if (points != null)
			'''via «points»'''
	}
	
	def decorations(InternalEdge edge) {
			edge.decorators?.map[toGratext].join(' ')
	}
	
	
	def toGratext(_Point p) {
		'''(«p.x»,«p.y»)'''
	}
	
	def toGratext(_Decoration dec) {
		'''decorate "«dec.nameHint»" at («dec.locationShift.x»,«dec.locationShift.y»)'''
	}
	
	def edges(InternalNode node) {
		node.getOutgoing(InternalEdge).map[toGratext].join('\n')
	}
	
	def toGratext(Iterable<EStructuralFeature> ftrs, EObject obj) {
		switch obj {
			InternalModelElement: ftrs.filter[featureID != InternalPackage.INTERNAL_MODEL_ELEMENT__ID]
			default: ftrs
		}.map[toGratext(obj)].filterNull.join('\n')
	}
	
	def toGratext(EStructuralFeature ftr, EObject obj) {
		val v = obj.eGet(ftr)
		if (v != null) {
			val value = switch v {
				List<?>: '[ ' + v.map[toGratextValue].join(', ') + ' ]'
				default: v.toGratextValue
			}
			if (value != null)
				ftr.name + ' ' + value
		}
	}
	
	def Object toGratextValue(Object it) {
		switch it {
			ModelElement: internalElement?.nonInternalID
			InternalModelElement: nonInternalID
			Type: internalElement.toGratextValue
			String: '"' + replace("\\","\\\\").replace('"', '\\"').replace('\n', '\\n') + '"'
			Date: '"' + new SimpleDateFormat("HH:mm:ss MM/dd/yyyy").format(it) + '"'
			EObject: '''
				«name» «nonInternalID» {
						«attributes»
					}''' 
			default: it
		}
	}
	
	def getNonInternalID(EObject it) {
		switch it {
			IdentifiableElement: id
			InternalIdentifiableElement: {
				val nonInternal = element
				if (!nonInternal?.id.nullOrEmpty)
					return nonInternal.id
				val index = id?.lastIndexOf("_INTERNAL")
				if (index > 0)
					id.substring(0, index)
				else id
			}
			default: getID
		}
	}
	
}
		
