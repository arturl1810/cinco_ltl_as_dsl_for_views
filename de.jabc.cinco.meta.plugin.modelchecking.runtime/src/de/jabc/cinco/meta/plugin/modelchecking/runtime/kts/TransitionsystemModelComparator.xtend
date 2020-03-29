package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.ModelComparator
import java.util.Set

class TransitionsystemModelComparator implements ModelComparator<TransitionsystemModel> {

	override areEqualModels(TransitionsystemModel model1, TransitionsystemModel model2) {
		if (model1 !== null && model2 !== null) {
			return model1.nodes.size == model2.nodes.size && model1.edges.size == model2.edges.size &&
				model1.nodes.containsAllNodes(model2.nodes) && model1.edges.containsAllEdges(model2.edges)
		}
		false
	}

	def containsAllNodes(Set<LinkedBasicCheckableNode> nodes1, Set<LinkedBasicCheckableNode> nodes2) {
		!nodes1.exists [
			val firstNode = it
			!nodes2.exists[equalNodes(firstNode, it)]
		]
	}

	def containsAllEdges(Set<LinkedBasicCheckableEdge> edges1, Set<LinkedBasicCheckableEdge> edges2) {
		!edges1.exists [
			val firstEdge = it
			!edges2.exists[equalEdges(firstEdge, it)]
		]
	}

	def equalNodes(LinkedBasicCheckableNode node1, LinkedBasicCheckableNode node2) {
		node1.id == node2.id && node1.isStartNode == node2.isStartNode &&
			node1.atomicPropositions.size == node2.atomicPropositions.size &&
			node1.atomicPropositions.containsAll(node2.atomicPropositions)
	}

	def equalEdges(LinkedBasicCheckableEdge edge1, LinkedBasicCheckableEdge edge2) {
		edge1.source.id == edge2.source.id && edge1.target.id == edge2.target.id &&
			edge1.labels.size == edge2.labels.size && edge1.labels.containsAll(edge2.labels)
	}
}
