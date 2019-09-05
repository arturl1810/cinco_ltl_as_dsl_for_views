package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

abstract class AbstractBasicCheckableModel<N extends AbstractBasicCheckableNode<E>, E extends AbstractBasicCheckableEdge<N>> implements CheckableModel<N,E> {
		
	abstract def N createNode(String id, boolean isStartNode, Set<String> atomicPropositions)
	abstract def E createEdge(N source, N target, Set<String> labels)
	
	val Set<N> nodes
	val Set<E> edges
	
	new(){
		nodes = newHashSet
		edges = newHashSet
	}
	
	override getId(N node) {
		node.id
	}
	
	override isStartNode(N node) {
		node.isStartNode
	}
	
	override addNewNode(String id, boolean isStartNode, Set<String> atomicPropositions) {
		val checkNode = createNode(id, isStartNode, atomicPropositions)	
		nodes.add(checkNode)
	}
	
	override addNewEdge(N source, N target, Set<String> labels) {
		val checkEdge = createEdge(source, target, labels)
		source.addOutgoing(checkEdge)
		target.addIncoming(checkEdge)
		edges.add(checkEdge)
	}
	
	override getNodes() {
		nodes
	}
	
	override getEdges() {
		edges
	}
}