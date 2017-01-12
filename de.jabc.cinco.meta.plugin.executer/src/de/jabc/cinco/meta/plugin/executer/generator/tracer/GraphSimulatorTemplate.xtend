package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.NodeContainer

class GraphSimulatorTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "GraphSimulator.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import java.util.HashMap;
	import java.util.LinkedList;
	import java.util.List;
	import java.util.Map;
	import java.util.Set;
	import java.util.stream.Collectors;
	import java.util.stream.Stream;
	
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CGraphModel;
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CModelElementContainer;
	import graphicalgraphmodel.CNode;
	import «graphmodel.sourceCApiPackage».C«graphmodel.graphModel.name»;
	import «graphmodel.CApiPackage».CExecutableEdge;
	import «graphmodel.CApiPackage».CExecutableNode;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CMetaLevel;
	import «graphmodel.CApiPackage».CPattern;
	import «graphmodel.CApiPackage».C«graphmodel.graphModel.name»ES;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.StateMatch;
	import «graphmodel.tracerPackage».match.model.TransitionMatch;
	
	public class GraphSimulator {
		
		private C«graphmodel.graphModel.name» graph;
		
		private List<CMetaLevel> metaLevels;
		
		private Map<CModelElementContainer,LTSMatch> lts;
		
		private NodeSimulator nodeSimulator;
		private EdgeSimulator edgeSimulator;
		private ContainerSimulator containerSimulator;
		
		public GraphSimulator(C«graphmodel.graphModel.name» graph,C«graphmodel.graphModel.name»ES patternGraph)
		{
			this.graph = graph;
			this.metaLevels = patternGraph.getCMetaLevels();
			
			this.containerSimulator = new ContainerSimulator();
			this.edgeSimulator = new EdgeSimulator();
			this.nodeSimulator = new NodeSimulator();
			
			containerSimulator.setGraphSimulator(this);
			containerSimulator.setNodeSimulator(nodeSimulator);
			containerSimulator.setPatternGraph(patternGraph);	
			
			nodeSimulator.setEdgeSimulator(edgeSimulator);
			nodeSimulator.setGraphSimulator(this);
			nodeSimulator.setPatternGraph(patternGraph);
			
			edgeSimulator.setContainerSimulator(containerSimulator);
			edgeSimulator.setNodeSimulator(nodeSimulator);
			
			lts = new HashMap<CModelElementContainer, LTSMatch>();
		}
		
		
		public final LTSMatch simulate()
		{
						
			for(CMetaLevel levelDefinition : metaLevels)
			{
				// for each level definition try to build up a LTS match
				
				LTSMatch ltsMatch = simulateLTS(levelDefinition,graph,graph);
				if(ltsMatch == null){
					continue;
				}
				return ltsMatch;
			}
			
			return null;
		}
		
		public final LTSMatch simulateLTS(CMetaLevel levelDefinition,CGraphModel graphModel,CModelElementContainer container)
		{
			if(lts.containsKey(container)){
				return lts.get(container);
			}
			LTSMatch ltsMatch = new LTSMatch(graphModel,container);
			lts.put(container, ltsMatch);
			
			/**
			 * 1. phase: find matches for the patterns
			 */
			List<Match> initializingStateMatches = getMatches(levelDefinition.getCInitializings(),ltsMatch);
			
			if(initializingStateMatches.isEmpty()){
				return null;
			}
			
			ltsMatch.setAbstractStartStates(initializingStateMatches);
			
			ltsMatch.setAbstractStates(getMatches(levelDefinition.getCDefaults(),ltsMatch));	
			
			ltsMatch.setAbstractEndStates(getMatches(levelDefinition.getCTerminatings(),ltsMatch));
						
			ltsMatch.setAbstractTransitions(getMatches(levelDefinition.getCMetaTransitions(),ltsMatch));
						
			/**
			 * 2. phase, connect states to states by transitions
			 */
					
			for(StateMatch match:ltsMatch.getAllStateMatches())
			{
				if(match.getStartPoint() instanceof CEdge){
					CNode connectingSource = ((CEdge)match.getStartPoint()).getSourceElement();
					// find source as 
					for(TransitionMatch transition:ltsMatch.getTransitions())
					{
						if(transition.getEndPoint() instanceof CNode){
							if(connectingSource.equals(transition.getEndPoint())){
								match.getIncoming().add(transition);
								transition.setTarget(match);
							}
						}
					}
				}
	
				if(match.getEndPoint() instanceof CEdge){
					CNode connectingSource = ((CEdge)match.getEndPoint()).getTargetElement();
					// find source as 
					for(TransitionMatch transition:ltsMatch.getTransitions())
					{
						if(transition.getStartPoint() instanceof CNode){
							if(connectingSource.equals(transition.getStartPoint())){
								match.getOutgoing().add(transition);
								transition.setSource(match);
							}
						}
					}
				}
			}
			
			for(TransitionMatch match:ltsMatch.getTransitions())
			{
				if(match.getStartPoint() instanceof CEdge){
					CNode connectingSource = ((CEdge)match.getStartPoint()).getSourceElement();
					// find source as 
					for(StateMatch state:ltsMatch.getAllStateMatches())
					{
						if(state.getEndPoint() instanceof CNode){
							if(connectingSource.equals(state.getEndPoint())){
								match.setSource(state);
								state.getOutgoing().add(match);
							}
						}
					}
				}
	
				if(match.getEndPoint() instanceof CEdge){
					CNode connectingSource = ((CEdge)match.getEndPoint()).getTargetElement();
					// find source as 
					for(StateMatch state:ltsMatch.getAllStateMatches())
					{
						if(state.getStartPoint() instanceof CNode){
							if(connectingSource.equals(state.getStartPoint())){
								match.setTarget(state);
								state.getIncoming().add(match);
							}
						}
					}
				}
			}
			
			return ltsMatch;
		}
		
		
		
		
		private List<Match> getMatches(List<? extends CPattern> elements,LTSMatch ltsMatch)
		{
			return elements.stream().flatMap(pattern->matchPattern(pattern,ltsMatch).stream()).collect(Collectors.toList());
		}
		
		private List<Match> matchPattern(CPattern pattern,LTSMatch ltsMatch)
		{
			List<Match> abstractMatches = new LinkedList<Match>();
			
			// cache: pattern element -> list of matching graph model elements
			Map<CModelElement,Set<CModelElement>> foundMatches = new HashMap<CModelElement, Set<CModelElement>>();
			
			
			/**
			 * Inner and outer level states
			 */
			
			
			// try to find simulation starting by any node of the graph
			List<CExecutableNode> cenOL = pattern.getCExecutableNodes().stream().filter(n->TypeChecker.isNodeOuterLevelState(n)).collect(Collectors.toList());
			if(!cenOL.isEmpty())
			{
				«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
					if(cenOL.get(0) instanceof «graphmodel.CApiPackage».C«n.name»OuterLevelState)
					{
						ltsMatch.getContainer().getAllCNodes().forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromOLNode(node, («graphmodel.CApiPackage».C«n.name»OuterLevelState)cenOL.get(0),foundMatches,ltsMatch)));
					}
				«ENDFOR»
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			List<CExecutableContainer> cecOL = pattern.getCExecutableContainers().stream().filter(n->TypeChecker.isContainerOuterLevelState(n)).collect(Collectors.toList());
			if(!cecOL.isEmpty())
			{
				«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer].filter[isPrime]»
				if(cecOL.get(0) instanceof «graphmodel.CApiPackage».C«node.name»OuterLevelState)
				{
					ltsMatch.getContainer().getAllCContainers().forEach(container->addMatches(pattern, abstractMatches, containerSimulator.simulatePatternFromOLContainer(container,(«graphmodel.CApiPackage».C«node.name»OuterLevelState) cecOL.get(0),foundMatches,ltsMatch)));					
				}
				«ENDFOR»
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			List<CExecutableContainer> cecIL = pattern.getCExecutableContainers().stream().filter(n->TypeChecker.isContainerInnerLevelState(n)).collect(Collectors.toList());
			if(!cecIL.isEmpty())
			{
				«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer]»
				if(cecIL.get(0) instanceof «graphmodel.CApiPackage».C«node.name»InnerLevelState)
				{
					ltsMatch.getContainer().getAllCContainers().forEach(container->addMatches(pattern, abstractMatches, containerSimulator.simulatePatternFromILContainer(container,(«graphmodel.CApiPackage».C«node.name»InnerLevelState) cecIL.get(0),foundMatches,ltsMatch)));
				}
				«ENDFOR»
				return abstractMatches;
			}
			
			/**
			 * One level states
			 */
			
			// try to find simulation starting by any node of the graph
			if(!pattern.getCExecutableNodes().isEmpty())
			{
				ltsMatch.getContainer().getAllCNodes().forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(node, pattern.getCExecutableNodes().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			if(!pattern.getCExecutableContainers().isEmpty())
			{
				ltsMatch.getContainer().getAllCContainers().forEach(container->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(container, pattern.getCExecutableContainers().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			
			/**
			 * Only Transitions
			 */
			
			// try to find simulation starting by any container of the graph
			Set<CExecutableEdge> edges = Stream.concat(
					pattern.getAllCNodes().stream().flatMap(node->node.getIncoming().stream().filter(edge->(edge instanceof CExecutableEdge)).map(edge->(CExecutableEdge)edge)),
					pattern.getAllCNodes().stream().flatMap(node->node.getOutgoing().stream().filter(edge->(edge instanceof CExecutableEdge)).map(edge->(CExecutableEdge)edge))
					).collect(Collectors.toSet());
			if(!edges.isEmpty())
			{
				ltsMatch.getContainer().getAllCEdges().forEach(edge->addMatches(pattern, abstractMatches, edgeSimulator.simulatePatternFromEdge(edge, edges.stream().findFirst().get(),foundMatches,ltsMatch)));	
				return abstractMatches;
			}
			
			return abstractMatches;
		}
	
	
		private void addMatches(CPattern pattern,List<Match> abstractMatches, Match match) {
			if(match != null) {
				match.setPattern(pattern);
				abstractMatches.add(match);
			}
		}
	}
	
	'''
	
}