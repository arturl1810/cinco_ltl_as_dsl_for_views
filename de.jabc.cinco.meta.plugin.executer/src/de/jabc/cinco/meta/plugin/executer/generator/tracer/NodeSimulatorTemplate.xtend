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
	
	import org.eclipse.graphiti.mm.pictograms.Diagram;
	
	import graphmodel.ModelElement;
	import graphmodel.Node;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.apiPackage».Pattern;
	import «graphmodel.apiPackage».«graphmodel.graphModel.name»ES;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	
	public class NodeSimulator {
		
		private EdgeSimulator edgeSimulator;
		
		private GraphSimulator graphSimulator;
		private «graphmodel.graphModel.name»ES patternGraph;
		
		public Match simulatePatternFromNode(Node startGraphNode,Node startPatternNode,Map<ModelElement,Set<ModelElement>> foundMatches,LTSMatch ltsMatch)
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
				foundMatches.put(startPatternNode, new HashSet<ModelElement>());
			}
			
			/**
			 * 2. Type check
			 */
			if(!TypeChecker.checkType(startGraphNode, startPatternNode))
			{
				return null;
			}
			
			Match match = new Match();
			match.setPattern((Pattern) startPatternNode.getContainer());
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
		«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
		public Match simulatePatternFromOLNode(Node startGraphNode,«graphmodel.apiPackage».«n.name»OuterLevelState startPatternNode,Map<ModelElement,Set<ModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			Match match = simulatePatternFromNode(startGraphNode,(Node) startPatternNode, foundMatches,ltsMatch);
			
			if(match==null) 
			{
				return null;
			}
			
			MetaLevel level = ((«graphmodel.apiPackage».«n.name»OuterLevelState)startPatternNode.getModelElement()).getLevel();
			
			CMetaLevel cMetaLevel = (CMetaLevel) this.patternGraph.getModelElements().stream().filter(n->n.getModelElement().getId().equals(level.getId())).findFirst().get();
			
			«graphmodel.sourceApiPackage».«n.name» startNode = («graphmodel.sourceApiPackage».«n.name») startGraphNode.getModelElement();
			«graphmodel.sourceApiPackage».«graphmodel.modelElement.name» graphModel = startNode.getProcedure().getRootElement();
					
			«graphmodel.sourceApiPackage».«n.primeAttrType» reference = («graphmodel.sourceApiPackage».«n.primeAttrType») graphModel.getAllNodes().stream().filter(n->n.getModelElement().getId().equals(startNode.get«n.primeAttrName.toFirstUpper»().getId())).findFirst().get();
			
			LTSMatch lts = graphSimulator.simulateLTS(cMetaLevel,startGraphNode.getRootElement(),reference);
			
			match.setLevel(lts);
			
			return match;
		}
		«ENDFOR»
	
		public void setEdgeSimulator(EdgeSimulator edgeSimulator) {
			this.edgeSimulator = edgeSimulator;
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