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
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CExecutableEdge;
	import «graphmodel.CApiPackage».CExecutableNode;
	import «graphmodel.apiPackage».BorderElement;
	import «graphmodel.tracerPackage».match.model.Match;
	
	public class BorderMatcher {
	
		public static void setBorder(Match match,CNode node,CNode cExecutabelNode){
			if(node instanceof CContainer){
				if(cExecutabelNode instanceof CExecutableContainer){
					setBorder(match,(CContainer) node, (CExecutableContainer) cExecutabelNode);
					return;
				}
	
			}
			if(cExecutabelNode instanceof CExecutableNode){
				setBorder(match,node, (CExecutableNode) cExecutabelNode);
				return;
			}
	
		}
		
		public static void setBorder(Match match,CEdge edge,CExecutableEdge cExecutableEdge)
		{
			if(cExecutableEdge.getBorder() == BorderElement.START || cExecutableEdge.getBorder() == BorderElement.START_AND_END){
				match.setStartPoint(edge);
			}
			if(cExecutableEdge.getBorder() == BorderElement.END || cExecutableEdge.getBorder() == BorderElement.START_AND_END){
				match.setEndPoint(edge);
			}
		}
		
		public static void setBorder(Match match,CContainer container,CExecutableContainer cExecutableContainer)
		{
			if(cExecutableContainer.getBorder() == BorderElement.START || cExecutableContainer.getBorder() == BorderElement.START_AND_END){
				match.setStartPoint(container);
			}
			if(cExecutableContainer.getBorder() == BorderElement.END || cExecutableContainer.getBorder() == BorderElement.START_AND_END){
				match.setEndPoint(container);
			}
		}
		
		
		
		public static void setBorder(Match match,CNode node,CExecutableNode cExecutableNode)
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