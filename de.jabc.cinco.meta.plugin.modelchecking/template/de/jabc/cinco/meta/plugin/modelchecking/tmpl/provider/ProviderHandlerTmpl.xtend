package de.jabc.cinco.meta.plugin.modelchecking.tmpl.provider

import de.jabc.cinco.meta.plugin.template.FileTemplate
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class ProviderHandlerTmpl extends FileTemplate{
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	String providerPath
	String providerClassName
	
	override init(){
		providerPath = model.providerPath
		providerClassName = providerPath?.substring(providerPath.lastIndexOf(".") + 1)
	}
	
	
	override template() '''
		package «package»;
		
		import java.util.Set;
		import java.util.List;
		
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FulfillmentConstraint;
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
		
		import «model.fqBeanName»;	
		«IF model.providerExists»
			import «model.beanPackage».util.«model.name.toOnlyFirstUpper»Switch;
			«FOR node:model.nodes.filter[!isIsAbstract]»
				import «node.fqBeanName»;
			«ENDFOR»
			«FOR edge:model.edges.filter[!isIsAbstract]»
				import «edge.fqBeanName»;
			«ENDFOR»
			
			import «providerPath»;
			
			
			
			public class ProviderHandler extends «model.name.toOnlyFirstUpper»Switch<Set<String>>{
				
				«providerClassName» provider = new «providerClassName»();
				
				«FOR node:model.nodes.filter[!isIsAbstract] SEPARATOR '\n'»
					@Override
					public Set<String> case«node.name»(«node.name» node) {
						return provider.getAtomicPropositions(node);
					}
				«ENDFOR»
				«FOR edge:model.edges.filter[!isIsAbstract] SEPARATOR '\n'»
					@Override
					public Set<String> case«edge.name»(«edge.name» edge) {
						return provider.getEdgeLabels(edge);
					}
				«ENDFOR»
				
				public Set<graphmodel.Edge> getReplacementEdges(«model.name» model){
					return provider.getReplacementEdges(model);
				}
				
				public Set<String> getReplacementEdgeLabels(List<graphmodel.Node> path, Set<String> intendedEdgeLabels){
					return provider.getReplacementEdgeLabels(path, intendedEdgeLabels);
				}
				
				public boolean isSupportNode(graphmodel.Node node){
					return provider.isSupportNode(node);
				}
		«ELSE»
			public class ProviderHandler{
		«ENDIF»
		
			public boolean fulfills(«model.name» model, CheckableModel<?,?> checkableModel, Set<graphmodel.Node> satisfyingNodes){
				boolean intendedCheckResult = FulfillmentConstraint.«model.fulfillmentConstraint».fulfills(checkableModel, satisfyingNodes);
				«IF model.providerExists»
					return provider.fulfills(model, satisfyingNodes, intendedCheckResult);
				«ELSE»
					return intendedCheckResult;
				«ENDIF»
			}
		}	
	'''
	
	override getTargetFileName() '''ProviderHandler.java'''
}
