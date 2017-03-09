package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalNode
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ICopyContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.PictogramLink
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.features.AbstractCopyFeature
import org.eclipse.graphiti.mm.pictograms.Anchor
import org.eclipse.emf.common.notify.Adapter

class CincoCopyFeature extends AbstractCopyFeature {
	new(IFeatureProvider fp) {
		super(fp) // TODO Auto-generated constructor stub
	}

	override void copy(ICopyContext context) {
		var PictogramElement[] pes = context.getPictogramElements()
		var Object[] objects = newArrayOfSize(pes.length)
		var result = pes.map[(it as PictogramElement).copyPE]
		for (i : 0..<pes.length) {
			objects.set(i, result.get(i))
		}
		println(result)
		putToClipboard(objects)
	}

	override boolean canCopy(ICopyContext context) {
		true
	}
	
	def copyPE(PictogramElement pe) {
		switch (pe) {
			Shape: pe.copy as PictogramElement
			Connection: pe.copy as PictogramElement
		}
	}
	
	def copy(InternalModelElement ime) {
		var InternalModelElement meCopy
		switch (ime) {
			InternalContainer : meCopy = ime.copy
			InternalNode: meCopy = ime.copy
			InternalEdge: meCopy = ime.copy
		}
		meCopy.id = EcoreUtil::generateUUID
		meCopy
	}
	
	def create EcoreUtil.copy(s) copy(Shape s) {
		link = s.link.copy
		if (s instanceof ContainerShape) {
			(it as ContainerShape).children.clear;
			(it as ContainerShape).children.addAll(s.children.map[copy])
		}
	}
	
//	def create EcoreUtil.copy(cs) copy(ContainerShape cs) {
//		children.clear
//		children.addAll(cs.children.map[copy])
//	}
	
	def create EcoreUtil.copy(conn) copy(Connection conn) {
		link = conn.link.copy
		start = conn.start.copy
		end = conn.end.copy
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
	}
	
	def InternalNode create EcoreUtil.copy(n) copy(InternalNode n) {
		incoming.clear
		outgoing.clear
		incoming.addAll(n.incoming.map[copy])
		outgoing.addAll(n.outgoing.map[copy])
	}
	
	def InternalContainer create (c as InternalNode).copy as InternalContainer copy(InternalContainer c) {
		modelElements.addAll(modelElements.map[copy])
	}
	
	def InternalEdge create EcoreUtil.copy(e) copy(InternalEdge e) {
		set_sourceElement(e.get_sourceElement.copy)
		set_targetElement(e.get_targetElement.copy)
	}
	
}
