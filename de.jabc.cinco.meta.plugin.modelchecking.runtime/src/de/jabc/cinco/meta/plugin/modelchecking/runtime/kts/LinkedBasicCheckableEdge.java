package de.jabc.cinco.meta.plugin.modelchecking.runtime.kts;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.AbstractBasicCheckableEdge;

public class LinkedBasicCheckableEdge extends AbstractBasicCheckableEdge<LinkedBasicCheckableNode>{

	public LinkedBasicCheckableEdge(LinkedBasicCheckableNode source, LinkedBasicCheckableNode target,
			Set<String> labels) {
		super(source, target, labels);
	}

}