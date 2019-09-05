package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

abstract class AbstractBasicCheckableEdge<N> {
	protected val N source
	protected val N target
	protected val Set<String> labels
	
	new (N source, N target, Set<String> labels){
		this.labels = newHashSet
		this.source = source
		this.target = target
		
		addLabels(labels)
	}
	
	def addLabels(String labels){
		if (labels !== null){
			for (label : labels.replaceAll(" ","").split(",")) {
				this.labels.add(label)
			}
		}
	}
	
	def addLabels(Set<String> labels){
		if (labels !== null){
			for (label : labels){
				addLabels(label)
			}
		}
	}
	
	def getSource() {source}
	def getTarget() {target}
	def getLabels() {labels}
		
}