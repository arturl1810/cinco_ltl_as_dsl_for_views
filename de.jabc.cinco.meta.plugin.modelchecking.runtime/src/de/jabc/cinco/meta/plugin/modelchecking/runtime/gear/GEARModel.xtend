package de.jabc.cinco.meta.plugin.modelchecking.runtime.gear

import de.metaframe.gear.model.Model

class GEARModel extends de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableModel implements Model<de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode, de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge> {

	override getAtomicPropositions(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode node) {
		node.atomicPropositions
	}

	override getEdgeLabels(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge edge) {
		edge.labels
	}

	override getEdgeType(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge edge) {
		Model$EdgeType.MUST
	}

	override getIdentifier(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode node) {
		node.id
	}

	override getIncomingEdges(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode node) {
		node.incoming
	}

	override getOutgoingEdges(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode node) {
		node.outgoing
	}

	override getInitialNodes() {
		nodes.filter[isStartNode].toSet
	}

	override getSource(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge edge) {
		edge.source
	}

	override getTarget(de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge edge) {
		edge.target
	}
}
