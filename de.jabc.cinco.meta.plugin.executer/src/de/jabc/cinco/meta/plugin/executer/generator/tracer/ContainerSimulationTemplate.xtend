package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.NodeContainer

class ContainerSimulationTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "ContainerSimulator.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import java.util.Map;
	import java.util.Set;
	
	import graphmodel.Container;
	import graphmodel.ModelElement;
	import «graphmodel.apiPackage».ExecutableContainer;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.apiPackage».ReferencedMetaLevel;
	import «graphmodel.apiPackage».«graphmodel.graphModel.name»ES;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.apiPackage».ReferencedMetaLevel;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	
	public class ContainerSimulator {
		
		private NodeSimulator nodeSimulator;
		
		private GraphSimulator graphSimulator;
		private «graphmodel.graphModel.name»ES patternGraph;
		
		public Match simulatePatternFromContainer(Container startGraphContainer, ExecutableContainer startPatternContainer,Map<ModelElement,Set<ModelElement>> foundMatches,LTSMatch ltsMatch) {
			Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
			
			if(match != null)
			{
				// add all elements in the container the match
				// if the container itself is a match
				match.getElements().addAll(startGraphContainer.getModelElements(ModelElement.class));
			}
			
			return match;
		}
		
		«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer]»
			public Match simulatePatternFromILContainer(Container startGraphContainer, «graphmodel.apiPackage».«node.name»InnerLevelState startPatternContainer,Map<ModelElement,Set<ModelElement>> foundMatches,LTSMatch ltsMatch) {
				Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
				
				ReferencedMetaLevel referencedMetaLevel = startPatternContainer.getReferencedMetaLevels().get(0);
				MetaLevel level = referencedMetaLevel.getLevel();
				
				MetaLevel metaLevel = (MetaLevel) this.patternGraph.getModelElements().stream().filter(n->n.getId().equals(level.getId())).findFirst().get();
				LTSMatch lts = graphSimulator.simulateLTS(metaLevel,startGraphContainer.getRootElement(),startGraphContainer);
				
				match.setLevel(lts);
				return match;
			}
			«IF node.isPrime»
				public Match simulatePatternFromOLContainer(Container startGraphContainer, «graphmodel.sourceApiPackage».«node.name»OuterLevelState startPatternContainer,Map<ModelElement,Set<ModelElement>> foundMatches,LTSMatch ltsMatch) {
					Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
							
					MetaLevel level = ((«graphmodel.apiPackage».«node.name»OuterLevelState)startPatternContainer.getModelElement()).getLevel();
					
					MetaLevel metaLevel = (CMetaLevel) this.patternGraph.getModelElements().stream().filter(n->n.getId().equals(level.getId())).findFirst().get();
					
					«graphmodel.sourceApiPackage».«node.primeAttrType» reference = («graphmodel.sourceApiPackage».«node.primeAttrType») startGraphContainer.getRootElement().getAllNodes().stream().filter(n->n.getId().equals(startContainer.get«node.primeAttrName.toFirstUpper»().getId())).findFirst().get();
					
					LTSMatch lts = graphSimulator.simulateLTS(metaLevel,startGraphContainer.getRootElement(),startGraphContainer);
					
					match.setLevel(lts);
					
					return match;
				}
			«ENDIF»
		«ENDFOR»
		
	
		public void setNodeSimulator(NodeSimulator nodeSimulator) {
			this.nodeSimulator = nodeSimulator;
		}
	
		public void setGraphSimulator(GraphSimulator graphSimulator) {
			this.graphSimulator = graphSimulator;
		}
	
		public void setPatternGraph(«graphmodel.graphModel.name»ES patternGraph) {
			this.patternGraph = patternGraph;
		}
		
		
		
	}
	
	'''
	
}