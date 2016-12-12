package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.NodeContainer

class EdgeSimulatorTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "EdgeSimulator.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import java.util.Map;
	import java.util.Set;
	import java.util.stream.Collectors;
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CExecutableEdge;
	import «graphmodel.CApiPackage».CExecutableNode;
	import «graphmodel.CApiPackage».CPattern;
	import «graphmodel.CApiPackage».CSourceConnector;
	import «graphmodel.CApiPackage».CTargetConnector;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	
	public class EdgeSimulator {
		
		private NodeSimulator nodeSimulator;
		private ContainerSimulator containerSimulator;
			
		
		public Match simulatePatternFromEdge(CEdge edge, CExecutableEdge cExecutableEdge,Map<CModelElement, Set<CModelElement>> foundMatches,LTSMatch ltsMatch) {
			
			Match match = new Match();
			match.setRoot(ltsMatch);
			
			match.getElements().add(edge);
			
			BorderMatcher.setBorder(match,edge,cExecutableEdge);
			
			//check incoming
			Match sourceMatch = simulatePatternFromIncommingEdge(edge, cExecutableEdge,foundMatches,ltsMatch);
			if(sourceMatch == null){
				// pattern did not match
				return null;
			}
			//check outgoing
			Match targetMatch = simulatePatternFromOutgoingEdge(edge, cExecutableEdge,foundMatches,ltsMatch);
			if(targetMatch == null){
				// pattern did not match
				return null;
			}
			
			match.unionMatch(sourceMatch);
			match.unionMatch(targetMatch);
			return match;
		}
		
		public Match simulateSurroundingEdges(CNode startGraphNode, CNode startPatternNode,Map<CModelElement, Set<CModelElement>> foundMatches,LTSMatch ltsMatch) {
			
			Match match = new Match();
			match.setPattern((CPattern) startPatternNode.getContainer());
			match.setRoot(ltsMatch);
			
			// simulate incoming edges
			for(CExecutableEdge patternEdge:startPatternNode.getIncoming(CExecutableEdge.class)) {
				// for each incoming pattern edge
				Set<CEdge> fittingEdges = startGraphNode.
						getIncoming().
						stream().
						filter(n->TypeChecker.checkType(n, patternEdge)).
						collect(Collectors.toSet());
				
				
				// check cardinality
				if(CardinalityChecker.checkCardinality(patternEdge, fittingEdges.size()))
				{
					for(CEdge edge:startGraphNode.getIncoming()){
						Match sourceMatch = simulatePatternFromIncommingEdge(edge, patternEdge,foundMatches,ltsMatch);
						if(sourceMatch == null){
							// pattern did not match
							return null;
						}
						match.unionMatch(sourceMatch);
					}
				}
				else{
					return null;
				}
				
			}
			
			for(CExecutableEdge patternEdge:startPatternNode.getOutgoing(CExecutableEdge.class)) {
				
				Set<CEdge> fittingEdges = startGraphNode.
						getOutgoing().
						stream().
						filter(n->TypeChecker.checkType(n, patternEdge)).
						collect(Collectors.toSet());
				
				// check cardinality
				if(CardinalityChecker.checkCardinality(patternEdge, fittingEdges.size()))
				{
					for(CEdge edge:startGraphNode.getOutgoing()){
						Match targetMatch = simulatePatternFromOutgoingEdge(edge, patternEdge,foundMatches,ltsMatch);
						if(targetMatch == null){
							// pattern did not match
							return null;
						}
						match.unionMatch(targetMatch);
					}
				}
				else{
					return null;
				}
				
			}
			
			return match;
		}
	
		public Match simulatePatternFromIncommingEdge(CEdge startGraphEdge,CExecutableEdge startPatternEdge, Map<CModelElement, Set<CModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			
			CNode targetPattern = startPatternEdge.getTargetElement();
			CNode targetNode = startGraphEdge.getTargetElement();
			
			return simulateNode(startGraphEdge, foundMatches, targetPattern, targetNode, CTargetConnector.class,ltsMatch);
		}
		
		/**
		 * precondition: type check passed
		 * precondition: cardinality check passed
		 * @param startGraphEdge
		 * @param startPatternEdge
		 * @param foundMatches
		 * @return
		 */
		public Match simulatePatternFromOutgoingEdge(CEdge startGraphEdge,CExecutableEdge startPatternEdge, Map<CModelElement, Set<CModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			
			CNode sourcePattern = startPatternEdge.getSourceElement();
			CNode sourceNode = startGraphEdge.getSourceElement();
			
			return simulateNode(startGraphEdge, foundMatches, sourcePattern, sourceNode, CSourceConnector.class,ltsMatch);
		}
		
		public Match simulateNode(CEdge startGraphEdge,Map<CModelElement, Set<CModelElement>> foundMatches, CNode pattern,CNode node, Class<? extends CNode> clazz,LTSMatch ltsMatch) {
			
			Match match = new Match();
			match.setPattern((CPattern) pattern.getContainer());
			match.setRoot(ltsMatch);
			
			/**
			 * 1. Check if target is a connector
			 */
			if(clazz.isInstance(pattern)){
				return match;
			}
			
			match.getElements().add(startGraphEdge);
			
			/**
			 * 2. Check pattern type of the source and continue with the source node
			 */
			
			Match connectorMatch = null;
			
			«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer]»
				if(pattern instanceof «graphmodel.CApiPackage».C«node.name»InnerLevelState && node instanceof CContainer){
					connectorMatch = containerSimulator.simulatePatternFromILContainer((CContainer)node, («graphmodel.CApiPackage».C«node.name»InnerLevelState)pattern,foundMatches,ltsMatch);
					if(connectorMatch != null){
						match.unionMatch(connectorMatch);
						return match;
					}
				}
				«IF node.isPrime»
					if(pattern instanceof «graphmodel.CApiPackage».C«node.name»OuterLevelState && node instanceof CContainer){
						connectorMatch = containerSimulator.simulatePatternFromOLContainer((CContainer)node, («graphmodel.CApiPackage».C«node.name»OuterLevelState)pattern,foundMatches,ltsMatch);
						if(connectorMatch != null){
							match.unionMatch(connectorMatch);
							return match;
						}
					}
				«ENDIF»
			«ENDFOR»
			«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
				if(pattern instanceof «graphmodel.CApiPackage».C«n.name»OuterLevelState){
					connectorMatch = nodeSimulator.simulatePatternFromOLNode(node, («graphmodel.CApiPackage».C«n.name»OuterLevelState)pattern,foundMatches,ltsMatch);
					if(connectorMatch != null){
						match.unionMatch(connectorMatch);
						return match;
					}
				}
			«ENDFOR»
			
			if(pattern instanceof CExecutableNode){
				connectorMatch = nodeSimulator.simulatePatternFromNode(node, (CExecutableNode)pattern,foundMatches,ltsMatch);
				if(connectorMatch != null){
					match.unionMatch(connectorMatch);
					return match;
				}
				
			}
			if(pattern instanceof CExecutableContainer){
				connectorMatch = containerSimulator.simulatePatternFromContainer((CContainer)node, (CExecutableContainer)pattern,foundMatches,ltsMatch);
				if(connectorMatch != null){
					match.unionMatch(connectorMatch);
					return match;
				}
			}
			return null;
		}
	
		public void setNodeSimulator(NodeSimulator nodeSimulator) {
			this.nodeSimulator = nodeSimulator;
		}
	
		public void setContainerSimulator(ContainerSimulator containerSimulator) {
			this.containerSimulator = containerSimulator;
		}
		
		
	}
	
	'''
	
}