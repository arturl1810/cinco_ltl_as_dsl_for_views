package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class NodeSimulatorTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "NodeSimulator.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import java.util.HashSet;
	import java.util.Map;
	import java.util.Set;
	
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CExecutableNodeOuterLevelState;
	import «graphmodel.CApiPackage».CMetaLevel;
	import «graphmodel.CApiPackage».CPattern;
	import «graphmodel.CApiPackage».C«graphmodel.graphModel.name»ES;
	import «graphmodel.apiPackage».ExecutableNodeOuterLevelState;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	
	public class NodeSimulator {
		
		private EdgeSimulator edgeSimulator;
		
		private GraphSimulator graphSimulator;
		private C«graphmodel.graphModel.name»ES patternGraph;
		
		public Match simulatePatternFromNode(CNode startGraphNode,CNode startPatternNode,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			
			
			/**
			 * 1. Has this node been checked ? 
			 */
			if(foundMatches.containsKey(startPatternNode)){
				if(foundMatches.get(startPatternNode).contains(startGraphNode)){
					// terminate matching path
					return new Match();		
				}
			}
			else{
				foundMatches.put(startPatternNode, new HashSet<CModelElement>());
			}
			
			/**
			 * 2. Type check
			 */
			if(TypeChecker.checkType(startGraphNode, startPatternNode))
			{
				return null;
			}
			
			Match match = new Match();
			match.setPattern((CPattern) startPatternNode.getContainer());
			match.setRoot(ltsMatch);
			match.getElements().add(startGraphNode);
			
			BorderMatcher.setBorder(match,startGraphNode,startPatternNode);
			
			foundMatches.get(startPatternNode).addAll(match.getElements());
			
			/**
			 * 3. simulate edges
			 * For each possible edge type, check the cardinalities
			 */
			Match edgeMatch = edgeSimulator.simulateSurroundingEdges(startGraphNode, startPatternNode, foundMatches,ltsMatch);
			if(edgeMatch == null)
			{
				return null;
			}
			match.unionMatch(edgeMatch);
			return match;
		}
		
		public Match simulatePatternFromOLNode(CNode startGraphNode,CExecutableNodeOuterLevelState startPatternNode,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			Match match = simulatePatternFromNode(startGraphNode,(CNode) startPatternNode, foundMatches,ltsMatch);
			
			MetaLevel level = ((ExecutableNodeOuterLevelState)startPatternNode.getModelElement()).getLevel();
			
			CMetaLevel cMetaLevel = this.patternGraph.findCMetaLevel(level);
			LTSMatch lts = graphSimulator.simulateLTS(cMetaLevel,startGraphNode.getCRootElement(),startGraphNode.getContainer());
			
			match.setLevel(lts);
			
			return match;
		}
	
		public void setEdgeSimulator(EdgeSimulator edgeSimulator) {
			this.edgeSimulator = edgeSimulator;
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