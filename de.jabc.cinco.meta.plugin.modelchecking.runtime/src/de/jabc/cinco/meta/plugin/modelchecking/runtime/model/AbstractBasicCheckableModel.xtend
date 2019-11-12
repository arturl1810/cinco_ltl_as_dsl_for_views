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
		val checkableNode = createNode(id, isStartNode, atomicPropositions)	
		nodes.add(checkableNode)
	}
	
	override addNewEdge(N source, N target, Set<String> labels) {
		val checkableEdge = createEdge(source, target, labels)
		source.addOutgoing(checkableEdge)
		target.addIncoming(checkableEdge)
		edges.add(checkableEdge)
	}
	
	override getNodes() {
		nodes
	}
	
	override getEdges() {
		edges
	}
}