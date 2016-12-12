package de.jabc.cinco.meta.plugin.executer.generator.tracer

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
	
	import graphicalgraphmodel.CEdge;
	import graphicalgraphmodel.CNode;
	import «graphmodel.CApiPackage».CExecutableContainer;
	import «graphmodel.CApiPackage».CExecutableEdge;
	import «graphmodel.CApiPackage».CExecutableNode;
	
	public class TypeChecker {
		
		
		public static boolean checkType(CNode graphNode,CNode patternNode){
			if(patternNode instanceof CExecutableNode){
				return checkType(graphNode, (CExecutableNode)patternNode);
			}
			if(patternNode instanceof CExecutableContainer){
				return checkType(graphNode, (CExecutableContainer)patternNode);
			}
			return false;
		}
		
		/**
		 * If the pattern is of this type, the graph model node has to be at least of this type
		 * @param graphNode
		 * @param patternNode
		 * @return
		 */
		public static boolean checkType(CNode graphNode,CExecutableContainer patternNode)
		{
			if(patternNode instanceof «graphmodel.CApiPackage».CPlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.containers»
				if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
					if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
						return false;
					}
				}
				if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»InnerLevelState){
					if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
						return false;
					}
				}
			«ENDFOR»
			«FOR node:graphmodel.containers.filter[n|(n.modelElement as NodeContainer).isPrime]»
				if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»OuterLevelState){
					if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
						return false;
					}
				}
			«ENDFOR»
			return true;
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
			«FOR node:graphmodel.exclusivelyNodes»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»){
				if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			«FOR node:graphmodel.exclusivelyNodes.filter[n|n.modelElement.isPrime]»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»OuterLevelState){
				if(!(graphNode instanceof «graphmodel.sourceCApiPackage».C«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		public static boolean isNodeOuterLevelState(CExecutableNode patternNode)
		{
			«FOR node:graphmodel.nodes.filter[n|n.modelElement.isPrime]»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»OuterLevelState){
				return true;
			}
			«ENDFOR»
			return false;
		}
		
		public static boolean isContainerOuterLevelState(CExecutableContainer patternNode)
		{
			«FOR node:graphmodel.containers.filter[n|(n.modelElement as NodeContainer).isPrime]»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»OuterLevelState){
				return true;
			}
			«ENDFOR»
			return false;
		}
		
		public static boolean isContainerInnerLevelState(CExecutableContainer patternNode)
		{
			«FOR node:graphmodel.containers»
			if(patternNode instanceof «graphmodel.CApiPackage».C«node.modelElement.name»InnerLevelState){
				return true;
			}
			«ENDFOR»
			return false;
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
		
	}
	
	'''
	
}