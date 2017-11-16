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
	
	import graphmodel.Edge;
	import graphmodel.Node;
	import «graphmodel.apiPackage».ExecutableContainer;
	import «graphmodel.apiPackage».ExecutableEdge;
	import «graphmodel.apiPackage».ExecutableNode;
	
	public class TypeChecker {
		
		
		public static boolean checkType(Node graphNode,Node patternNode){
			if(patternNode instanceof ExecutableNode){
				return checkType(graphNode, (ExecutableNode)patternNode);
			}
			if(patternNode instanceof ExecutableContainer){
				return checkType(graphNode, (ExecutableContainer)patternNode);
			}
			return false;
		}
		
		/**
		 * If the pattern is of this type, the graph model node has to be at least of this type
		 * @param graphNode
		 * @param patternNode
		 * @return
		 */
		public static boolean checkType(Node graphNode,ExecutableContainer patternNode)
		{
			if(patternNode instanceof «graphmodel.apiPackage».PlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.containers»
				if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»){
					if(!(graphNode instanceof «graphmodel.sourceApiPackage».«node.modelElement.name»)){
						return false;
					}
				}
				if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»InnerLevelState){
					if(!(graphNode instanceof «graphmodel.sourceApiPackage».«node.modelElement.name»)){
						return false;
					}
				}
			«ENDFOR»
			«FOR node:graphmodel.containers.filter[n|(n.modelElement as NodeContainer).isPrime]»
				if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»OuterLevelState){
					if(!(graphNode instanceof «graphmodel.sourceApiPackage».«node.modelElement.name»)){
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
		public static boolean checkType(Node graphNode,ExecutableNode patternNode)
		{
			if(patternNode instanceof «graphmodel.apiPackage».PlaceholderContainer){
				return true;
			}
			«FOR node:graphmodel.exclusivelyNodes»
			if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»){
				if(!(graphNode instanceof «graphmodel.sourceApiPackage».«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			«FOR node:graphmodel.exclusivelyNodes.filter[n|n.modelElement.isPrime]»
			if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»OuterLevelState){
				if(!(graphNode instanceof «graphmodel.sourceApiPackage».«node.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
		public static boolean isNodeOuterLevelState(ExecutableNode patternNode)
		{
			«FOR node:graphmodel.nodes.filter[n|n.modelElement.isPrime]»
			if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»OuterLevelState){
				return true;
			}
			«ENDFOR»
			return false;
		}
		
		public static boolean isContainerOuterLevelState(ExecutableContainer patternNode)
		{
			«FOR node:graphmodel.containers.filter[n|(n.modelElement as NodeContainer).isPrime]»
			if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»OuterLevelState){
				return true;
			}
			«ENDFOR»
			return false;
		}
		
		public static boolean isContainerInnerLevelState(ExecutableContainer patternNode)
		{
			«FOR node:graphmodel.containers»
			if(patternNode instanceof «graphmodel.apiPackage».«node.modelElement.name»InnerLevelState){
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
		public static boolean checkType(Edge graphEdge,ExecutableEdge patternEdge)
		{
			if(patternEdge instanceof «graphmodel.apiPackage».PlaceholderEdge){
				return true;
			}
			«FOR edge:graphmodel.edges»
			if(patternEdge instanceof «graphmodel.apiPackage».«edge.modelElement.name»){
				if(!(graphEdge instanceof «graphmodel.sourceApiPackage».«edge.modelElement.name»)){
					return false;
				}
			}
			«ENDFOR»
			return true;
		}
		
	}
	
	'''
	
}