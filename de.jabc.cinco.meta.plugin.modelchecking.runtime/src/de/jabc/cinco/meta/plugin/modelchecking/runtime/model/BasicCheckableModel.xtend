package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

class BasicCheckableModel extends AbstractBasicCheckableModel<BasicCheckableNode, BasicCheckableEdge>{
	
	override createNode(String id, boolean isStartNode, Set<String> atomicPropositions) {
		new BasicCheckableNode(id, isStartNode, atomicPropositions)
	}
	
	override createEdge(BasicCheckableNode source, BasicCheckableNode target, Set<String> labels) {
		new BasicCheckableEdge(source, target, labels)
	}
}