package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class LTSMatchTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "LTSMatch.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.model;
	
	import java.util.LinkedList;
	import java.util.List;
	import java.util.stream.Collectors;
	import java.util.stream.Stream;
	
	import graphmodel.GraphModel;
	import graphmodel.ModelElementContainer;
	
	public class LTSMatch {
		private List<StateMatch> startStates;
		private List<StateMatch> states;
		private List<StateMatch> endStates;
		private List<TransitionMatch> transitions;
		private ModelElementContainer container;
		private GraphModel graph;
		
		public LTSMatch(GraphModel graph,ModelElementContainer container)
		{
			this.startStates = new LinkedList<StateMatch>();
			this.endStates = new LinkedList<StateMatch>();
			this.states = new LinkedList<StateMatch>();
			this.transitions = new LinkedList<TransitionMatch>();
			this.container = container;
			this.graph = graph;
		}
		
		public List<Match> getAllMatches()
		{
			return Stream.concat(startStates.stream(), Stream.concat(states.stream(), Stream.concat(endStates.stream(), transitions.stream()))).collect(Collectors.toList());
		}
	
		public List<StateMatch> getStartStates() {
			return startStates;
		}
	
		public void setStartStates(List<StateMatch> startStates) {
			this.startStates = startStates;
		}
		
		public void setAbstractStartStates(List<Match> startStates) {
			this.startStates = startStates.stream().map(n->new StateMatch(n)).collect(Collectors.toList());
		}
	
		public List<StateMatch> getStates() {
			return states;
		}
	
		public void setStates(List<StateMatch> states) {
			this.states = states;
		}
		
		public void setAbstractStates(List<Match> states) {
			this.states = states.stream().map(n->new StateMatch(n)).collect(Collectors.toList());
		}
	
		public List<TransitionMatch> getTransitions() {
			return transitions;
		}
	
		public void setTransitions(List<TransitionMatch> transitions) {
			this.transitions = transitions;
		}
		
		public void setAbstractTransitions(List<Match> transitions) {
			this.transitions = transitions.stream().map(n->new TransitionMatch(n)).collect(Collectors.toList());
		}
	
		public List<StateMatch> getEndStates() {
			return endStates;
		}
	
		public void setEndStates(List<StateMatch> endStates) {
			this.endStates = endStates;
		}
		
		public void setAbstractEndStates(List<Match> endStates) {
			this.endStates = endStates.stream().map(n->new StateMatch(n)).collect(Collectors.toList());
		}
	
		public List<StateMatch> getAllStateMatches() {
			return Stream.concat(startStates.stream(), Stream.concat(states.stream(),endStates.stream())).collect(Collectors.toList());
		}
	
		public ModelElementContainer getContainer() {
			return container;
		}
	
		public void setContainer(ModelElementContainer container) {
			this.container = container;
		}
	
		public GraphModel getGraphModel() {
			return graph;
		}
	
		public void setGraphModel(GraphModel graph) {
			this.graph = graph;
		}
		
		
	}
	
	'''
	
}