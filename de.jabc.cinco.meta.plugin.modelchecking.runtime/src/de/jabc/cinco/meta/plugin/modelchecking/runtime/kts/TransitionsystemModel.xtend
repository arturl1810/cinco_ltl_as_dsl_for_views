package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.AbstractBasicCheckableModel
import de.metaframe.gear.model.Model
import java.util.Set

class TransitionsystemModel extends AbstractBasicCheckableModel<LinkedBasicCheckableNode, LinkedBasicCheckableEdge> implements Model<LinkedBasicCheckableNode, LinkedBasicCheckableEdge> {

	var idCounter = 1;

	override getAtomicPropositions(LinkedBasicCheckableNode node) {
		node.atomicPropositions
	}

	override getEdgeLabels(LinkedBasicCheckableEdge edge) {
		edge.labels
	}

	override getEdgeType(LinkedBasicCheckableEdge edge) {
		Model$EdgeType.MUST
	}

	override getIdentifier(LinkedBasicCheckableNode node) {
		node.id
	}

	override getIncomingEdges(LinkedBasicCheckableNode node) {
		node.incoming
	}

	override getOutgoingEdges(LinkedBasicCheckableNode node) {
		node.outgoing
	}

	override getInitialNodes() {
		nodes.filter[isStartNode].toSet
	}

	override getSource(LinkedBasicCheckableEdge edge) {
		edge.source
	}

	override getTarget(LinkedBasicCheckableEdge edge) {
		edge.target
	}

	override createNode(String id, boolean isStartNode, Set<String> atomicPropositions) {
		new LinkedBasicCheckableNode(createUniqueId(), id, isStartNode, atomicPropositions);
	}

	override createEdge(LinkedBasicCheckableNode source, LinkedBasicCheckableNode target, Set<String> labels) {
		new LinkedBasicCheckableEdge(source, target, labels)
	}

	override getId(LinkedBasicCheckableNode node) {
		node.linkedId
	}

	def createUniqueId() {
		return "internal_" + (idCounter++);
	}
}
