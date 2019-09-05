package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

class BasicCheckableEdge extends AbstractBasicCheckableEdge<BasicCheckableNode>{
	
	new(BasicCheckableNode source, BasicCheckableNode target, Set<String> labels) {
		super(source, target, labels)
	}
	
}