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
	
	import graphmodel.Container;
	import graphmodel.Edge;
	import graphmodel.ModelElement;
	import graphmodel.Node;
	import «graphmodel.apiPackage».ExecutableContainer;
	import «graphmodel.apiPackage».ExecutableEdge;
	import «graphmodel.apiPackage».ExecutableNode;
	import «graphmodel.apiPackage».Pattern;
	import «graphmodel.apiPackage».SourceConnector;
	import «graphmodel.apiPackage».TargetConnector;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	
	public class EdgeSimulator {
		
		private NodeSimulator nodeSimulator;
		private ContainerSimulator containerSimulator;
			
		
		public Match simulatePatternFromEdge(Edge edge, ExecutableEdge cExecutableEdge,Map<ModelElement, Set<ModelElement>> foundMatches,LTSMatch ltsMatch) {
			
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
		
		public Match simulateSurroundingEdges(Node startGraphNode, Node startPatternNode,Map<ModelElement, Set<ModelElement>> foundMatches,LTSMatch ltsMatch) {
			
			Match match = new Match();
			match.setPattern((Pattern) startPatternNode.getContainer());
			match.setRoot(ltsMatch);
			
			// simulate incoming edges
			for(ExecutableEdge patternEdge:startPatternNode.getIncoming(ExecutableEdge.class)) {
				// for each incoming pattern edge
				Set<Edge> fittingEdges = startGraphNode.
						getIncoming().
						stream().
						filter(n->TypeChecker.checkType(n, patternEdge)).
						collect(Collectors.toSet());
				
				
				// check cardinality
				if(CardinalityChecker.checkCardinality(patternEdge, fittingEdges.size()))
				{
					for(Edge edge:startGraphNode.getIncoming()){
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
			
			for(ExecutableEdge patternEdge:startPatternNode.getOutgoing(ExecutableEdge.class)) {
				
				Set<Edge> fittingEdges = startGraphNode.
						getOutgoing().
						stream().
						filter(n->TypeChecker.checkType(n, patternEdge)).
						collect(Collectors.toSet());
				
				// check cardinality
				if(CardinalityChecker.checkCardinality(patternEdge, fittingEdges.size()))
				{
					for(Edge edge:startGraphNode.getOutgoing()){
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
	
		public Match simulatePatternFromIncommingEdge(Edge startGraphEdge,ExecutableEdge startPatternEdge, Map<ModelElement, Set<ModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			
			Node targetPattern = startPatternEdge.getTargetElement();
			Node targetNode = startGraphEdge.getTargetElement();
			
			return simulateNode(startGraphEdge, foundMatches, targetPattern, targetNode, TargetConnector.class,ltsMatch);
		}
		
		/**
		 * precondition: type check passed
		 * precondition: cardinality check passed
		 * @param startGraphEdge
		 * @param startPatternEdge
		 * @param foundMatches
		 * @return
		 */
		public Match simulatePatternFromOutgoingEdge(Edge startGraphEdge,ExecutableEdge startPatternEdge, Map<ModelElement, Set<ModelElement>> foundMatches,LTSMatch ltsMatch)
		{
			
			Node sourcePattern = startPatternEdge.getSourceElement();
			Node sourceNode = startGraphEdge.getSourceElement();
			
			return simulateNode(startGraphEdge, foundMatches, sourcePattern, sourceNode, SourceConnector.class,ltsMatch);
		}
		
		public Match simulateNode(Edge startGraphEdge,Map<ModelElement, Set<ModelElement>> foundMatches, Node pattern,Node node, Class<? extends Node> clazz,LTSMatch ltsMatch) {
			
			Match match = new Match();
			match.setPattern((Pattern) pattern.getContainer());
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
				if(pattern instanceof «graphmodel.apiPackage».«node.name»InnerLevelState && node instanceof Container){
					connectorMatch = containerSimulator.simulatePatternFromILContainer((Container)node, («graphmodel.apiPackage».«node.name»InnerLevelState)pattern,foundMatches,ltsMatch);
					if(connectorMatch != null){
						match.unionMatch(connectorMatch);
						return match;
					}
				}
				«IF node.isPrime»
					if(pattern instanceof «graphmodel.apiPackage».«node.name»OuterLevelState && node instanceof Container){
						connectorMatch = containerSimulator.simulatePatternFromOLContainer((Container)node, («graphmodel.apiPackage».«node.name»OuterLevelState)pattern,foundMatches,ltsMatch);
						if(connectorMatch != null){
							match.unionMatch(connectorMatch);
							return match;
						}
					}
				«ENDIF»
			«ENDFOR»
			«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
				if(pattern instanceof «graphmodel.apiPackage».«n.name»OuterLevelState){
					connectorMatch = nodeSimulator.simulatePatternFromOLNode(node, («graphmodel.apiPackage».«n.name»OuterLevelState)pattern,foundMatches,ltsMatch);
					if(connectorMatch != null){
						match.unionMatch(connectorMatch);
						return match;
					}
				}
			«ENDFOR»
			
			if(pattern instanceof ExecutableNode){
				connectorMatch = nodeSimulator.simulatePatternFromNode(node, (ExecutableNode)pattern,foundMatches,ltsMatch);
				if(connectorMatch != null){
					match.unionMatch(connectorMatch);
					return match;
				}
				
			}
			if(pattern instanceof ExecutableContainer){
				connectorMatch = containerSimulator.simulatePatternFromContainer((Container)node, (ExecutableContainer)pattern,foundMatches,ltsMatch);
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