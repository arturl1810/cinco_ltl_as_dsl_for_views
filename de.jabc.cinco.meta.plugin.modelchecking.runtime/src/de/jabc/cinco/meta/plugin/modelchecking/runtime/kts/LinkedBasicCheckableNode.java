package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.AbstractBasicCheckableNode;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge;

public class LinkedBasicCheckableNode extends AbstractBasicCheckableNode<LinkedBasicCheckableEdge>{

	String linkedId;
	
	public LinkedBasicCheckableNode(String id, String linkedId, boolean isStartNode, Set<String> atomicPropositions) {
		super(id, isStartNode, atomicPropositions);
		this.linkedId = linkedId;
	}


	public String getLinkedId() {
		return linkedId;
	}
}
