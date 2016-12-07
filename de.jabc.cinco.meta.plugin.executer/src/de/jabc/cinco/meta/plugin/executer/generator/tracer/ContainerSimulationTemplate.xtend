package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

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
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CModelElement;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CExecutableContainerInnerLevelState;
	import «graphmodel.CApiPackage».CExecutableContainerOuterLevelState;
	import «graphmodel.CApiPackage».CMetaLevel;
	import «graphmodel.CApiPackage».CReferencedMetaLevel;
	import «graphmodel.CApiPackage».C«graphmodel.graphModel.name»ES;
	import «graphmodel.apiPackage».ExecutableContainerOuterLevelState;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.apiPackage».ReferencedMetaLevel;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	
	public class ContainerSimulator {
		
		private NodeSimulator nodeSimulator;
		
		private GraphSimulator graphSimulator;
		private C«graphmodel.graphModel.name»ES patternGraph;
		
		public Match simulatePatternFromContainer(CContainer startGraphContainer, CExecutableContainer startPatternContainer,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch) {
			Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
			
			if(match != null)
			{
				// add all elements in the container the match
				// if the container itself is a match
				match.getElements().addAll(startGraphContainer.getCModelElements(CModelElement.class));
			}
			
			return match;
		}
		
		public Match simulatePatternFromILContainer(CContainer startGraphContainer, CExecutableContainerInnerLevelState startPatternContainer,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch) {
			Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
			
			CReferencedMetaLevel cReferencedMetaLevel = startPatternContainer.getCReferencedMetaLevels().get(0);
			MetaLevel level = ((ReferencedMetaLevel)cReferencedMetaLevel.getModelElement()).getLevel();
			
			CMetaLevel cMetaLevel = this.patternGraph.findCMetaLevel(level);
			LTSMatch lts = graphSimulator.simulateLTS(cMetaLevel,startGraphContainer.getCRootElement(),startGraphContainer);
			
			match.setLevel(lts);
			return match;
		}
	
		public Match simulatePatternFromOLContainer(CContainer startGraphContainer, CExecutableContainerOuterLevelState startPatternContainer,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch) {
			Match match = nodeSimulator.simulatePatternFromNode(startGraphContainer, startPatternContainer, foundMatches,ltsMatch);
			
			MetaLevel level = ((ExecutableContainerOuterLevelState)startPatternContainer.getModelElement()).getLevel();
			
			CMetaLevel cMetaLevel = this.patternGraph.findCMetaLevel(level);
			LTSMatch lts = graphSimulator.simulateLTS(cMetaLevel,startGraphContainer.getCRootElement(),startGraphContainer);
			
			match.setLevel(lts);
			
			return match;
		}
	
		public void setNodeSimulator(NodeSimulator nodeSimulator) {
			this.nodeSimulator = nodeSimulator;
		}
	
		public void setGraphSimulator(GraphSimulator graphSimulator) {
			this.graphSimulator = graphSimulator;
		}
	
		public void setPatternGraph(C«graphmodel.graphModel.name»ES patternGraph) {
			this.patternGraph = patternGraph;
		}
		
		
		
	}
	
	'''
	
}