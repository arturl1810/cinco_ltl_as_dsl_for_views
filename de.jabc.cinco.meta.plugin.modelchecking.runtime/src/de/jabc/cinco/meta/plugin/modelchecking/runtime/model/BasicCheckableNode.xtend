package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

class BasicCheckableNode extends AbstractBasicCheckableNode<BasicCheckableEdge>{
	
	new(String id, boolean isStartNode, Set<String> atomicPropositions) {
		super(id, isStartNode, atomicPropositions)
	}
	
}