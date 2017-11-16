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
	
	import graphmodel.Edge;
	import graphmodel.GraphModel;
	import graphmodel.ModelElement;
	import graphmodel.ModelElementContainer;
	import graphmodel.Node;
	import «graphmodel.sourceApiPackage».«graphmodel.graphModel.name»;
	import «graphmodel.apiPackage».ExecutableEdge;
	import «graphmodel.apiPackage».ExecutableNode;
	import «graphmodel.apiPackage».ExecutableContainer;
	import «graphmodel.apiPackage».MetaLevel;
	import «graphmodel.apiPackage».Pattern;
	import «graphmodel.apiPackage».«graphmodel.graphModel.name»ES;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.model.Match;
	import «graphmodel.tracerPackage».match.model.StateMatch;
	import «graphmodel.tracerPackage».match.model.TransitionMatch;
	
	public class GraphSimulator {
		
		private «graphmodel.graphModel.name» graph;
		
		private List<MetaLevel> metaLevels;
		
		private Map<ModelElementContainer,LTSMatch> lts;
		
		private NodeSimulator nodeSimulator;
		private EdgeSimulator edgeSimulator;
		private ContainerSimulator containerSimulator;
		
		public GraphSimulator(«graphmodel.graphModel.name» graph,«graphmodel.graphModel.name»ES patternGraph)
		{
			this.graph = graph;
			this.metaLevels = patternGraph.getMetaLevels();
			
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
			
			lts = new HashMap<ModelElementContainer, LTSMatch>();
		}
		
		
		public final LTSMatch simulate()
		{
						
			for(MetaLevel levelDefinition : metaLevels)
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
		
		public final LTSMatch simulateLTS(MetaLevel levelDefinition,GraphModel graphModel,ModelElementContainer container)
		{
			if(lts.containsKey(container)){
				return lts.get(container);
			}
			LTSMatch ltsMatch = new LTSMatch(graphModel,container);
			lts.put(container, ltsMatch);
			
			/**
			 * 1. phase: find matches for the patterns
			 */
			List<Match> initializingStateMatches = getMatches(levelDefinition.getInitializings(),ltsMatch);
			
«««			if(initializingStateMatches.isEmpty()){
«««				return null;
«««			}
			
			ltsMatch.setAbstractStartStates(initializingStateMatches);
			
			ltsMatch.setAbstractStates(getMatches(levelDefinition.getDefaults(),ltsMatch));	
			
			ltsMatch.setAbstractEndStates(getMatches(levelDefinition.getTerminatings(),ltsMatch));
						
			ltsMatch.setAbstractTransitions(getMatches(levelDefinition.getMetaTransitions(),ltsMatch));
						
			/**
			 * 2. phase, connect states to states by transitions
			 */
					
			for(StateMatch match:ltsMatch.getAllStateMatches())
			{
				if(match.getStartPoint() instanceof Edge){
					Node connectingSource = ((Edge)match.getStartPoint()).getSourceElement();
					// find source as 
					for(TransitionMatch transition:ltsMatch.getTransitions())
					{
						if(transition.getEndPoint() instanceof Node){
							if(connectingSource.equals(transition.getEndPoint())){
								match.getIncoming().add(transition);
								transition.setTarget(match);
							}
						}
					}
				}
	
				if(match.getEndPoint() instanceof Edge){
					Node connectingSource = ((Edge)match.getEndPoint()).getTargetElement();
					// find source as 
					for(TransitionMatch transition:ltsMatch.getTransitions())
					{
						if(transition.getStartPoint() instanceof Node){
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
				if(match.getStartPoint() instanceof Edge){
					Node connectingSource = ((Edge)match.getStartPoint()).getSourceElement();
					// find source as 
					for(StateMatch state:ltsMatch.getAllStateMatches())
					{
						if(state.getEndPoint() instanceof Node){
							if(connectingSource.equals(state.getEndPoint())){
								match.setSource(state);
								state.getOutgoing().add(match);
							}
						}
					}
				}
	
				if(match.getEndPoint() instanceof Edge){
					Node connectingSource = ((Edge)match.getEndPoint()).getTargetElement();
					// find source as 
					for(StateMatch state:ltsMatch.getAllStateMatches())
					{
						if(state.getStartPoint() instanceof Node){
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
		
		
		
		
		private List<Match> getMatches(List<? extends Pattern> elements,LTSMatch ltsMatch)
		{
			return elements.stream().flatMap(pattern->matchPattern(pattern,ltsMatch).stream()).collect(Collectors.toList());
		}
		
		private List<Match> matchPattern(Pattern pattern,LTSMatch ltsMatch)
		{
			List<Match> abstractMatches = new LinkedList<Match>();
			
			// cache: pattern element -> list of matching graph model elements
			Map<ModelElement,Set<ModelElement>> foundMatches = new HashMap<ModelElement, Set<ModelElement>>();
			
			
			/**
			 * Inner and outer level states
			 */
			
			
			// try to find simulation starting by any node of the graph
			List<ExecutableNode> cenOL = pattern.getExecutableNodes().stream().filter(n->TypeChecker.isNodeOuterLevelState(n)).collect(Collectors.toList());
			if(!cenOL.isEmpty())
			{
				«FOR n:graphmodel.exclusivelyNodes.map[n|n.modelElement as mgl.Node].filter[isPrime]»
					if(cenOL.get(0) instanceof «graphmodel.apiPackage».«n.name»OuterLevelState)
					{
						ltsMatch.getContainer().getAllNodes().forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromOLNode(node, («graphmodel.apiPackage».«n.name»OuterLevelState)cenOL.get(0),foundMatches,ltsMatch)));
					}
				«ENDFOR»
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			List<ExecutableContainer> cecOL = pattern.getExecutableContainers().stream().filter(n->TypeChecker.isContainerOuterLevelState(n)).collect(Collectors.toList());
			if(!cecOL.isEmpty())
			{
				«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer].filter[isPrime]»
				if(cecOL.get(0) instanceof «graphmodel.apiPackage».«node.name»OuterLevelState)
				{
					ltsMatch.getContainer().getAllContainers().forEach(container->addMatches(pattern, abstractMatches, containerSimulator.simulatePatternFromOLContainer(container,(«graphmodel.apiPackage».«node.name»OuterLevelState) cecOL.get(0),foundMatches,ltsMatch)));					
				}
				«ENDFOR»
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			List<ExecutableContainer> cecIL = pattern.getExecutableContainers().stream().filter(n->TypeChecker.isContainerInnerLevelState(n)).collect(Collectors.toList());
			if(!cecIL.isEmpty())
			{
				«FOR node:graphmodel.containers.map[n|n.modelElement as NodeContainer]»
				if(cecIL.get(0) instanceof «graphmodel.apiPackage».«node.name»InnerLevelState)
				{
					ltsMatch.getContainer().getAllContainers().forEach(container->addMatches(pattern, abstractMatches, containerSimulator.simulatePatternFromILContainer(container,(«graphmodel.apiPackage».«node.name»InnerLevelState) cecIL.get(0),foundMatches,ltsMatch)));
				}
				«ENDFOR»
				return abstractMatches;
			}
			
			/**
			 * One level states
			 */
			
			// try to find simulation starting by any node of the graph
			if(!pattern.getExecutableNodes().isEmpty())
			{
				ltsMatch.getContainer().getAllNodes().forEach(node->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(node, pattern.getExecutableNodes().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			// try to find simulation starting by any container of the graph
			if(!pattern.getExecutableContainers().isEmpty())
			{
				ltsMatch.getContainer().getAllContainers().forEach(container->addMatches(pattern, abstractMatches, nodeSimulator.simulatePatternFromNode(container, pattern.getExecutableContainers().get(0),foundMatches,ltsMatch)));
				return abstractMatches;
			}
			
			/**
			 * Only Transitions
			 */
			
			// try to find simulation starting by any container of the graph
			Set<ExecutableEdge> edges = Stream.concat(
					pattern.getAllNodes().stream().flatMap(node->node.getIncoming().stream().filter(edge->(edge instanceof ExecutableEdge)).map(edge->(ExecutableEdge)edge)),
					pattern.getAllNodes().stream().flatMap(node->node.getOutgoing().stream().filter(edge->(edge instanceof ExecutableEdge)).map(edge->(ExecutableEdge)edge))
					).collect(Collectors.toSet());
			if(!edges.isEmpty())
			{
				ltsMatch.getContainer().getAllEdges().forEach(edge->addMatches(pattern, abstractMatches, edgeSimulator.simulatePatternFromEdge(edge, edges.stream().findFirst().get(),foundMatches,ltsMatch)));	
				return abstractMatches;
			}
			
			return abstractMatches;
		}
	
	
		private void addMatches(Pattern pattern,List<Match> abstractMatches, Match match) {
			if(match != null) {
				match.setPattern(pattern);
				abstractMatches.add(match);
			}
		}
	}
	
	'''
	
}