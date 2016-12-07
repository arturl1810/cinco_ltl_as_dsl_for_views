package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

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
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CModelElement;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CPattern;
	
	public class Match {
	
		private CModelElement startPoint;
		
		private CModelElement endPoint;
		
		private Set<CModelElement> elements;
		
		private LTSMatch level;
		
		private CPattern pattern;
		
		private LTSMatch root;
		
		public Match()
		{
			this.elements = new HashSet<CModelElement>();
		}
	
		public Match(Set<CModelElement> matchingElements) {
			this.elements = matchingElements; 
		}
		
		public Match(Match match) {
			this.elements = match.getElements();
			this.level = match.getLevel();
		}
	
		public Set<CModelElement> getElements() {
			return elements;
		}
	
		public void setElements(Set<CModelElement> elements) {
			this.elements = elements;
		}
		
		public List<CEdge> getEdges()
		{
			return elements.stream().filter(n->n instanceof CEdge).map(n->(CEdge)n).collect(Collectors.toList());
		}
		
		public List<CNode> getNodes()
		{
			return elements.stream().filter(n->n instanceof CNode).map(n->(CNode)n).collect(Collectors.toList());
		}
		
		public List<CContainer> getContainers()
		{
			return elements.stream().filter(n->n instanceof CContainer).map(n->(CContainer)n).collect(Collectors.toList());
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
	
		public CPattern getPattern() {
			return pattern;
		}
	
		public void setPattern(CPattern pattern) {
			this.pattern = pattern;
		}
	
		public CModelElement getStartPoint() {
			return startPoint;
		}
	
		public void setStartPoint(CModelElement startPoint) {
			this.startPoint = startPoint;
		}
	
		public CModelElement getEndPoint() {
			return endPoint;
		}
	
		public void setEndPoint(CModelElement endPoint) {
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