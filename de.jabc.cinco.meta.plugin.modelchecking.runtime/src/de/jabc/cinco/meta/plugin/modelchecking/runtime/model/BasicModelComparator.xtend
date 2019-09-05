package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

class BasicModelComparator<M extends AbstractBasicCheckableModel<N,E>, N extends AbstractBasicCheckableNode<E>, E extends AbstractBasicCheckableEdge<N>> implements ModelComparator<M>{
	
	override areEqualModels(M model1, M model2){
		if (model1 !== null && model2 !== null){
			return model1.nodes.size == model2.nodes.size &&
				model1.edges.size == model2.edges.size &&
				model1.nodes.containsAllNodes(model2.nodes) &&
				model1.edges.containsAllEdges(model2.edges)		
		}
		false
	}
	
	def containsAllNodes(Set<N> nodes1, Set<N> nodes2){
		!nodes1.exists[
			val firstNode = it
			!nodes2.exists[equalNodes(firstNode, it)]
		]
	}
	
	def containsAllEdges(Set<E> edges1, Set<E> edges2){
		!edges1.exists[
			val firstEdge = it
			!edges2.exists[equalEdges(firstEdge, it)]
		]	
	}
		
	def equalNodes(N node1,N  node2){
		node1.id == node2.id &&
		node1.isStartNode == node2.isStartNode &&
		node1.atomicPropositions.size == node2.atomicPropositions.size &&
		node1.atomicPropositions.containsAll(node2.atomicPropositions) 
	}
	
	
	def equalEdges(E edge1,E edge2){
		edge1.source.id == edge2.source.id &&
		edge1.target.id == edge2.target.id &&
		edge1.labels.size == edge2.labels.size &&
		edge1.labels.containsAll(edge2.labels)
	}
}