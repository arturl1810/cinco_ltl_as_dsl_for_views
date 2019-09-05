package de.jabc.cinco.meta.plugin.modelchecking.tmpl.provider

import de.jabc.cinco.meta.plugin.template.FileTemplate

class ModelCheckingProviderTmpl extends FileTemplate{
	
	override getTargetFileName() '''«model.name»ModelCheckingProvider.java'''	
	
	override template() '''
		package «package»;
		
		«FOR node:model.nodes.filter[!isIsAbstract]»
			import «node.fqBeanName»;
		«ENDFOR»
		«FOR edge:model.edges.filter[!isIsAbstract]»
			import «edge.fqBeanName»;
		«ENDFOR»
		import «model.fqBeanName»;
		import java.util.HashSet;
		import java.util.Set;
		import java.util.List;
		
		public abstract class «model.name»ModelCheckingProvider {
			
			
			
			«FOR node:model.nodes.filter[!isIsAbstract]»
				public abstract Set<String> getAtomicPropositions(«node.name» node);
			«ENDFOR»
			«FOR edge:model.edges.filter[!isIsAbstract]»
				public abstract Set<String> getEdgeLabels(«edge.name» edge);
			«ENDFOR»
			
			public boolean isSupportNode(graphmodel.Node node){
				return false;
			}
			
			public Set<graphmodel.Edge> getReplacementEdges(«model.name» model){
				return new HashSet<graphmodel.Edge>();
			}
			
			public Set<String> getReplacementEdgeLabels(List<graphmodel.Node> path, Set<String> intendedEdgeLabels) {
				return intendedEdgeLabels;
			}
			
			public  boolean fulfills(«model.name» model, Set<graphmodel.Node> satisfyingNodes, boolean intendedCheckResult){
				return intendedCheckResult;
			}
		}
	'''
	
}
