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
	
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CMetaLevel;
	import «graphmodel.CApiPackage».CPattern;
	import «graphmodel.CApiPackage».C«graphmodel.graphModel.name»ES;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.sourceGraphitiPackage».«graphmodel.modelElement.name»Wrapper;
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
			if(!TypeChecker.checkType(startGraphNode, startPatternNode))
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
		«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
		public Match simulatePatternFromOLNode(CNode startGraphNode,«graphmodel.CApiPackage».C«n.name»OuterLevelState startPatternNode,Map<CModelElement,Set<CModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			Match match = simulatePatternFromNode(startGraphNode,(CNode) startPatternNode, foundMatches,ltsMatch);
			
			if(match==null) 
			{
				return null;
			}
			
			MetaLevel level = ((«graphmodel.apiPackage».«n.name»OuterLevelState)startPatternNode.getModelElement()).getLevel();
			
			CMetaLevel cMetaLevel = (CMetaLevel) this.patternGraph.getModelElements().stream().filter(n->n.getModelElement().getId().equals(level.getId())).findFirst().get();
			
			«graphmodel.sourceApiPackage».«n.name» startNode = («graphmodel.sourceApiPackage».«n.name») startGraphNode.getModelElement();
			«graphmodel.sourceCApiPackage».C«graphmodel.modelElement.name» graphModel = «graphmodel.modelElement.name»Wrapper.wrapGraphModel(startNode.getProcedure().getRootElement(), (Diagram) startNode.get«n.primeAttrName.toFirstUpper»().getRootElement().eResource().getContents().get(0));
					
			«graphmodel.sourceCApiPackage».C«n.primeAttrType» reference = («graphmodel.sourceCApiPackage».C«n.primeAttrType») graphModel.getAllCNodes().stream().filter(n->n.getModelElement().getId().equals(startNode.get«n.primeAttrName.toFirstUpper»().getId())).findFirst().get();
			
			LTSMatch lts = graphSimulator.simulateLTS(cMetaLevel,startGraphNode.getCRootElement(),reference);
			
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
	
		public void setPatternGraph(C«graphmodel.graphModel.name»ES patternGraph) {
			this.patternGraph = patternGraph;
		}
		
		
	}
	
	'''
	
}