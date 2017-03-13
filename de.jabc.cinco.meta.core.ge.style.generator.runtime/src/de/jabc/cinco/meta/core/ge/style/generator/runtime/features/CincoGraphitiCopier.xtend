package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import java.util.Collection
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.PictogramLink
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory
import org.eclipse.graphiti.mm.pictograms.Shape
import java.util.HashSet
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator

class CincoGraphitiCopier {
	
	def copyPE(Collection<PictogramElement> pes) {
		var copies = new HashSet<PictogramElement>()
		copies.addAll(pes.filter(Connection).map[copy])
		copies.addAll(pes.filter(Shape).map[copy])
		copies
	}
	
	def copyPE(PictogramElement pe) {
		var PictogramElement peCopy
		switch (pe) {
			Shape: peCopy = pe.copy as PictogramElement
			Connection: peCopy = pe.copy as PictogramElement
		}
	}
	
	def copy(InternalModelElement ime) {
		var InternalModelElement meCopy
		switch (ime) {
			InternalNode: meCopy = ime.copy
			InternalEdge: meCopy = ime.copy
		}
		meCopy.id = EcoreUtil::generateUUID
		meCopy
	}
	
	def create EcoreUtil.copy(s) copy(Shape s) {
		anchors.clear
		anchors.addAll(s.anchors.map[copy])
//		ConnectionDecorators may have no link
		link = s.link?.copy
		if (s instanceof ContainerShape) {
			(it as ContainerShape).children.clear;
			(it as ContainerShape).children.addAll(s.children.map[copy])
		}
	}
	
	def create EcoreUtil.copy(conn) copy(Connection conn) {
		link = conn.link.copy
		start = conn.start.copy
		end = conn.end.copy
		connectionDecorators.clear
		connectionDecorators.addAll(conn.connectionDecorators.map[copy as ConnectionDecorator])
	}
	
	def create PictogramsFactory.eINSTANCE.createPictogramLink copy(PictogramLink link) {
		pictogramElement = link.pictogramElement.copyPE
		businessObjects.clear
		businessObjects.addAll(link.businessObjects.map[(it as InternalModelElement).copy])
	}
	
	def create EcoreUtil.copy(a) copy(Anchor a) {
		outgoingConnections.clear
		incomingConnections.clear
		outgoingConnections.addAll(a.outgoingConnections.map[copy])
		incomingConnections.addAll(a.incomingConnections.map[copy])
		parent = (a.parent as Shape).copy
	}
	
	def InternalNode create EcoreUtil.copy(n) copy(InternalNode n) {
		if (n instanceof InternalModelElementContainer) {
			(it as InternalModelElementContainer).modelElements.clear()
			(it as InternalModelElementContainer).modelElements.addAll(n.modelElements.map[copy])
		}
	}
	
	def InternalContainer create (c as InternalNode).copy as InternalContainer copy(InternalContainer c) {
		modelElements.clear
		modelElements.addAll(modelElements.map[copy])
	}
	
	def InternalEdge create EcoreUtil.copy(e) copy(InternalEdge e) {
		set_sourceElement(e.get_sourceElement.copy)
		set_targetElement(e.get_targetElement.copy)
	}
	
	
}