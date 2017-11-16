package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import java.util.stream.Stream
import java.util.stream.Collectors

class MatchTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "Match.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.model;
	
	import java.util.HashSet;
	import java.util.List;
	import java.util.Set;
	import java.util.stream.Collectors;
	
	import graphmodel.Container;
	import graphmodel.Edge;
	import graphmodel.ModelElement;
	import graphmodel.Node;
	import «graphmodel.apiPackage».Pattern;
	
	public class Match {
	
		private ModelElement startPoint;
		
		private ModelElement endPoint;
		
		private Set<ModelElement> elements;
		
		private LTSMatch level;
		
		private Pattern pattern;
		
		private LTSMatch root;
		
		public Match()
		{
			this.elements = new HashSet<ModelElement>();
		}
	
		public Match(Set<ModelElement> matchingElements) {
			this.elements = matchingElements; 
		}
		
		public Match(Match match) {
			this.setElements(match.getElements());
			this.setEndPoint(match.getEndPoint());
			this.setStartPoint(match.getStartPoint());
			this.setLevel(match.getLevel());
			this.setPattern(match.getPattern());
			this.setRoot(match.getRoot());
		}
	
		public Set<ModelElement> getElements() {
			return elements;
		}
		
		public  Set<? extends ModelElement> getElements(Class<? extends ModelElement> c)
		{
			return elements.stream().filter(n->c.isInstance(n)).map(n->c.cast(n)).collect(Collectors.toSet());
		}
		
		«FOR node:Stream.concat(graphmodel.nodes.stream,graphmodel.edges.stream).collect(Collectors.toList)»
		«{
			var n = node.modelElement
			'''
			public Set<«graphmodel.sourceApiPackage».«n.name»> get«n.name»s() {
				return elements.stream().filter(n->n instanceof «graphmodel.sourceApiPackage».«n.name»).map(n->(«graphmodel.sourceApiPackage».«n.name»)n).collect(Collectors.toSet());
			}
			
			public «graphmodel.sourceApiPackage».«n.name» getFirst«n.name»() {
				return («graphmodel.sourceApiPackage».«n.name»)elements.stream().filter(n->n instanceof «graphmodel.sourceApiPackage».«n.name»).findFirst().orElse(null);
			}
					'''	
		}»
		«ENDFOR»
		public void setElements(Set<ModelElement> elements) {
			this.elements = elements;
		}
		
		public List<Edge> getEdges()
		{
			return elements.stream().filter(n->n instanceof Edge).map(n->(Edge)n).collect(Collectors.toList());
		}
		
		public List<Node> getNodes()
		{
			return elements.stream().filter(n->n instanceof Node).map(n->(Node)n).collect(Collectors.toList());
		}
		
		public List<Container> getContainers()
		{
			return elements.stream().filter(n->n instanceof Container).map(n->(Container)n).collect(Collectors.toList());
		}
	
		public LTSMatch getLevel() {
			return level;
		}
	
		public void setLevel(LTSMatch level) {
			this.level = level;
		}
		
		public void unionMatch(Match match)
		{
			this.elements.addAll(match.getElements());
			if(match.getLevel()!=null){
				this.level = match.getLevel();			
			}
			if(match.getPattern() != null){
				this.setPattern(match.getPattern());			
			}
			if(match.getStartPoint() != null){
				this.startPoint = match.getStartPoint();		
			}
			if(match.getEndPoint() != null){
				this.endPoint = match.getEndPoint();
			}
			if(match.getPattern() != null){
				this.pattern = match.getPattern();
			}
			if(match.getRoot() != null){
				this.root = match.getRoot();
			}
		}
	
		public Pattern getPattern() {
			return pattern;
		}
	
		public void setPattern(Pattern pattern) {
			this.pattern = pattern;
		}
	
		public ModelElement getStartPoint() {
			return startPoint;
		}
	
		public void setStartPoint(ModelElement startPoint) {
			this.startPoint = startPoint;
		}
	
		public ModelElement getEndPoint() {
			return endPoint;
		}
	
		public void setEndPoint(ModelElement endPoint) {
			this.endPoint = endPoint;
		}
	
		public LTSMatch getRoot() {
			return root;
		}
	
		public void setRoot(LTSMatch root) {
			this.root = root;
		}
		
		
		
	}
	
	'''
	
}