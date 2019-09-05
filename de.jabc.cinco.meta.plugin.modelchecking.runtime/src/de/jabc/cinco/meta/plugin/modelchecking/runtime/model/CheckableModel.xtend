package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

interface CheckableModel<N,E> {
	abstract def Set<N> getNodes()
	abstract def Set<E> getEdges()
	abstract def String getId(N node)
	abstract def boolean isStartNode(N node)
	abstract def void addNewNode(String id, boolean isStartNode, Set<String> atomicPropositions)
	abstract def void addNewEdge(N source, N target, Set<String> labels)
}