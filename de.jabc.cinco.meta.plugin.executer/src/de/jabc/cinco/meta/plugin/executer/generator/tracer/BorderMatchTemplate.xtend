package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class BorderMatchTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "BorderMatcher.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import graphmodel.Container;
	import graphmodel.Edge;
	import graphmodel.Node;
	import «graphmodel.apiPackage».ExecutableContainer;
	import «graphmodel.apiPackage».ExecutableEdge;
	import «graphmodel.apiPackage».ExecutableNode;
	import «graphmodel.apiPackage».BorderElement;
	import «graphmodel.tracerPackage».match.model.Match;
	
	public class BorderMatcher {
	
		public static void setBorder(Match match,Node node,Node cExecutabelNode){
			if(node instanceof Container){
				if(cExecutabelNode instanceof ExecutableContainer){
					setBorder(match,(Container) node, (ExecutableContainer) cExecutabelNode);
					return;
				}
	
			}
			if(cExecutabelNode instanceof ExecutableNode){
				setBorder(match,node, (ExecutableNode) cExecutabelNode);
				return;
			}
	
		}
		
		public static void setBorder(Match match,Edge edge,ExecutableEdge cExecutableEdge)
		{
			if(cExecutableEdge.getBorder() == BorderElement.START || cExecutableEdge.getBorder() == BorderElement.START_AND_END){
				match.setStartPoint(edge);
			}
			if(cExecutableEdge.getBorder() == BorderElement.END || cExecutableEdge.getBorder() == BorderElement.START_AND_END){
				match.setEndPoint(edge);
			}
		}
		
		public static void setBorder(Match match,Container container,ExecutableContainer cExecutableContainer)
		{
			if(cExecutableContainer.getBorder() == BorderElement.START || cExecutableContainer.getBorder() == BorderElement.START_AND_END){
				match.setStartPoint(container);
			}
			if(cExecutableContainer.getBorder() == BorderElement.END || cExecutableContainer.getBorder() == BorderElement.START_AND_END){
				match.setEndPoint(container);
			}
		}
		
		
		
		public static void setBorder(Match match,Node node,ExecutableNode cExecutableNode)
		{
			if(cExecutableNode.getBorder() == BorderElement.START || cExecutableNode.getBorder() == BorderElement.START_AND_END){
				match.setStartPoint(node);
			}
			if(cExecutableNode.getBorder() == BorderElement.END || cExecutableNode.getBorder() == BorderElement.START_AND_END){
				match.setEndPoint(node);
			}
		}
	}
	
	'''
	
}