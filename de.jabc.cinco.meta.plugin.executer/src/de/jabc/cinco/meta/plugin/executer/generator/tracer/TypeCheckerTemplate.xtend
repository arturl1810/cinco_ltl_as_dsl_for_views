package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.NodeContainer

class TypeCheckerTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "TypeChecker.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import graphicalgraphmodel.CContainer;
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CExecutableContainerInnerLevelState;
	import «graphmodel.CApiPackage».CExecutableContainerOuterLevelState;
	import «graphmodel.CApiPackage».CExecutableEdge;
	import «graphmodel.CApiPackage».CExecutableNode;
	import «graphmodel.CApiPackage».CExecutableNodeOuterLevelState;
	
	public class TypeChecker {
		
		
		public static boolean checkType(CNode graphNode,CNode patternNode){
			if(patternNode instanceof CExecutableNode){
				return checkType(graphNode, (CExecutableNode)patternNode);
			}
			if(patternNode instanceof CExecutableNodeOuterLevelState){
				return checkType(graphNode, (CExecutableNodeOuterLevelState)patternNode);
			}
			if(patternNode instanceof CExecutableContainer){
				return checkType(graphNode, (CExecutableContainer)patternNode);
			}
			if(patternNode instanceof CExecutableContainerInnerLevelState){
				return checkType(graphNode, (CExecutableContainerInnerLevelState)patternNode);
			}
			if(patternNode instanceof CExecutableContainerOuterLevelState){
				return checkType(graphNode, (CExecutableContainerOuterLevelState)patternNode);
			}
			return false;
		}
		
		/**
		 * If the pattern is of this type, the graph model node has to be at least of this type
		 * @param graphNode
		 * @param patternNode
		 * @return
		 */
		public static boolean checkType(CNode graphNode,CExecutableNode patternNode)
		{
			if(patternNode instanceof «graphmodel.CApiPackage».CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.nodes»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		/**
		 * If the pattern is of this type, the graph model outer level node has to be at least of this type
		 * @param graphNode
		 * @param patternNode
		 * @return
		 */
		public static boolean checkType(CNode graphNode,CExecutableNodeOuterLevelState patternNode)
		{
			if(patternNode instanceof info.scce.cinco.product.somegraph.esdsl.api.csomegraphes.CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.nodes.filter[n|n.modelElement.isPrime]»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		/**
		 * If the pattern is of this type, the graph model outer level node has to be at least of this type
		 * @param graphEdge
		 * @param patternEdge
		 * @return
		 */
		public static boolean checkType(CEdge graphEdge,CExecutableEdge patternEdge)
		{
			if(patternEdge instanceof info.scce.cinco.product.somegraph.esdsl.api.csomegraphes.CPlaceholderEdge){
				return true;
			}
			«FOR edge:graphmodel.edges»
			if(patternEdge instanceof «graphmodel.CApiPackage».C«edge.modelElement.name»){
				if(!(graphEdge instanceof «graphmodel.sourceCApiPackage».C«edge.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		/**
		 * If the pattern is of this type, the graph model inner level container has to be at least of this type
		 * @param graphContainer
		 * @param patternContainer
		 * @return
		 */
		public static boolean checkType(CContainer graphContainer,CExecutableContainerInnerLevelState patternContainer)
		{
			if(patternContainer instanceof info.scce.cinco.product.somegraph.esdsl.api.csomegraphes.CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.containers»
			if(patternContainer instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphContainer instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		/**
		 * If the pattern is of this type, the graph model container has to be at least of this type
		 * @param graphContainer
		 * @param patternContainer
		 * @return
		 */
		public static boolean checkType(CContainer graphContainer,CExecutableContainer patternContainer)
		{
			if(patternContainer instanceof info.scce.cinco.product.somegraph.esdsl.api.csomegraphes.CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.containers»
			if(patternContainer instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphContainer instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		/**
		 * If the pattern is of this type, the graph model outer level container has to be at least of this type
		 * @param graphContainer
		 * @param patternContainer
		 * @return
		 */
		public static boolean checkType(CContainer graphContainer,CExecutableContainerOuterLevelState patternContainer)
		{
			if(patternContainer instanceof info.scce.cinco.product.somegraph.esdsl.api.csomegraphes.CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.containers.filter[n|(n.modelElement as NodeContainer).isPrime]»
			if(patternContainer instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphContainer instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
	}
	
	'''
	
}