package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.stream.Collectors
import java.util.stream.Stream
import java.util.stream.StreamSupport

import graphmodel.Node
import graphmodel.Container
import graphmodel.ModelElement
import graphmodel.GraphModel
import graphmodel.GraphmodelPackage

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature

import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement

import org.eclipse.graphiti.ui.services.GraphitiUi
import graphmodel.Edge

abstract class BackupGenerator<T extends GraphModel> extends GratextGenerator<T> {

	private String idSuffix	= ""

	def setIdSuffix(String idSuffix) {
		this.idSuffix = idSuffix
	}

	def String fileExtension();

	override fileName(IFile sourceFile) {
		new Path(sourceFile.name).removeFileExtension.addFileExtension(fileExtension).toString
	}
	
	override template() {
		'''
		«model.name» «model.id + idSuffix» {
		  «model.attributes»
		  «model.nodes»
		}
		'''
	}
	
	def String gratext(Node node) {
		'''
		«node.name» «node.id + idSuffix» «node.placement» {
			«node.attributes»
			«node.containments»
			«node.edges»
		}
		''' 
	}
	
	def String gratext(Edge edge) {
		'''
		-«edge.name»-> «edge.targetElement.id + idSuffix» «edge.pe.route» «edge.pe.decorations» {
			id «edge.id + idSuffix»
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
			default: combine(cls.EAttributes, cls.EReferences, cls.ESuperTypes.map[attributes].flatten)
		}
	}
	
	def <T> combine(Collection<? extends T> l1, Collection<? extends T> l2, Iterable<? extends T> l3) {
		Stream.concat(l1.stream, Stream.concat(l2.stream, StreamSupport.stream(l3.spliterator, false))).collect(Collectors.toList)
	}
	
	def containments(Node node) {
		switch node {
			Container: node.allNodes.map[gratext].join('\n')
		}
	}
	
	def placement(Node node) {
		val ga = GraphitiUi.getLinkService.getPictogramElements(diagram, node).get(0).graphicsAlgorithm
		'''at «ga.x»,«ga.y» size «ga.width»,«ga.height»'''
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
		GraphitiUi.getLinkService.getPictogramElements(diagram, obj).get(0)
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
	
	def nodes(GraphModel model) {
		model.allNodes.map[gratext].join('\n')
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
			ModelElement: obj?.id + idSuffix
			String: '"' + obj.replace("\\","\\\\").replace('"', '\\"').replace('\n', '\\n') + '"'
			EObject: '''
				«obj.name» {
						«obj.attributes»
					}''' 
			default: obj
		}
	}
	
}