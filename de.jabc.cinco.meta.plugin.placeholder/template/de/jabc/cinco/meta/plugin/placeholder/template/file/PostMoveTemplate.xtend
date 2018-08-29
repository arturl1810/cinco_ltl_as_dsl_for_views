package de.jabc.cinco.meta.plugin.placeholder.template.file

import de.jabc.cinco.meta.plugin.placeholder.Constants
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node

class PostMoveTemplate extends FileTemplate {

	Node node
	Iterable<Node> placeholderParents
	
	new(Node placeholdedNode) {
		node = placeholdedNode
	}
	
	override getTargetFileName() 
		'''«Constants.getPostMoveHookClassName(node)».java'''
	
	override init(){
		placeholderParents = 
			model.getAllNodesWithAnnotation(Constants.PROJECT_ANNOTATION)
			.filter[cont | node.containingContainers.toSet.contains(cont)]
	}
	
	override template() '''
		package «package»;
		import de.jabc.cinco.meta.runtime.hook.CincoPostMoveHook;
		
		import graphmodel.ModelElementContainer;
		import graphmodel.Node;
		
		«FOR element : #{node} + placeholderParents.filter[it != node]»
			import «model.package».«model.name.toLowerCase».«element.getName()»;
		«ENDFOR»
		public class «Constants.getPostMoveHookClassName(node)» extends CincoPostMoveHook<«node.getName()»>{
			@Override
			public void postMove(«node.getName()» modelElement, ModelElementContainer source,
					ModelElementContainer target, int x, int y, int deltaX, int deltaY){
				«new CommonPartTemplate().takePlace(placeholderParents)»
			}
		}
	'''
	
}