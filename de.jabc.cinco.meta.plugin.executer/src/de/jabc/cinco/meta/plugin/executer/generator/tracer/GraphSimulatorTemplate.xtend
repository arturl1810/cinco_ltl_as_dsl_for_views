package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

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
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CGraphModel;
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CModelElementContainer;
	import graphicalgraphmodel.CNode;
	import «graphmodel.sourceCApiPackage».C«graphmodel.graphModel.name»;
	import «graphmodel.CApiPackage».CExecutableEdge;
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
		
		private List<CNode> graphNodes;
		private List<CContainer> graphContainer;
		private List<CEdge> graphEdge;
		
		private NodeSimulator nodeSimulator;
		private EdgeSimulator edgeSimulator;
		private ContainerSimulator containerSimulator;
		
		public GraphSimulator(C«graphmodel.graphModel.name» graph,C«graphmodel.graphModel.name»ES patternGraph)
		{
			this.graph = graph;
			this.graphNodes = graph.getAllCNodes().stream().filter(n->!(n instanceof CContainer)).collect(Collectors.toList());
			this.graphContainer = graph.getAllCContainers();
			this.graphEdge = graph.getAllCEdges();
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
		}
		
		
		public final LTSMatch simulate()
		{
			
			List<LTSMatch> lts = new LinkedList<LTSMatch>();
			
			for(CMetaLevel levelDefinition : metaLevels)
			{
				// for each level definition try to build up a LTS match
				
				LTSMatch ltsMatch = simulateLTS(levelDefinition,graph,graph);
				if(ltsMatch == null){
					continue;
				}
				lts.add(ltsMatch);
			}
			
			return lts.get(0);
		}
		
		public final LTSMatch simulateLTS(CMetaLevel levelDefinition,CGraphModel graphModel,CModelElementContainer container)
		{
			LTSMatch ltsMatch = new LTSMatch(graphModel,container);
			
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
								match.setTarget(state);
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
								match.setSource(state);
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
			if(!pattern.getCExecutableNodeOuterLevelStates().isEmpty())
			{
				this.graphNodes.forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(node, pattern.getCExecutableNodeOuterLevelStates().get(0),foundMatches,ltsMatch)));
	
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			if(!pattern.getCExecutableContainerInnerLevelStates().isEmpty())
			{
				this.graphContainer.forEach(container->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(container, pattern.getCExecutableContainerInnerLevelStates().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			if(!pattern.getCExecutableContainerOuterLevelStates().isEmpty())
			{
				this.graphContainer.forEach(container->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(container, pattern.getCExecutableContainerOuterLevelStates().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			
			/**
			 * One level states
			 */
			
			// try to find simulation starting by any node of the graph
			if(!pattern.getCExecutableNodes().isEmpty())
			{
				this.graphNodes.forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(node, pattern.getCExecutableNodes().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			if(!pattern.getCExecutableContainers().isEmpty())
			{
				this.graphContainer.forEach(container->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(container, pattern.getCExecutableContainers().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			
			/**
			 * Only Transitions
			 */
			
			// try to find simulation starting by any container of the graph
			if(!pattern.getAllCEdges().stream().filter(n->n instanceof CExecutableEdge).findAny().isPresent())
			{
				this.graphEdge.forEach(edge->addMatches(pattern, abstractMatches, edgeSimulator.simulatePatternFromEdge(edge, (CExecutableEdge) pattern.getAllCEdges().stream().filter(n->n instanceof CExecutableEdge).findFirst().get(),foundMatches,ltsMatch)));	
				return abstractMatches;
			}
			
			return null;
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