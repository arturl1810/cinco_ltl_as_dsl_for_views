package de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableNode
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableEdge
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableModel
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicModelComparator

abstract class AbstractBasicModelChecker<M extends BasicCheckableModel> implements ModelChecker<M, BasicCheckableNode, BasicCheckableEdge>{
	
	override getComparator() {
		new BasicModelComparator<M,BasicCheckableNode,BasicCheckableEdge>
	}
	
}
