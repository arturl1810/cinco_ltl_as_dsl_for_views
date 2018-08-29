package de.jabc.cinco.meta.plugin.placeholder.template.file

import de.jabc.cinco.meta.plugin.placeholder.Constants
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node

class PostCreateTemplate extends FileTemplate {
	
	Node node
	Iterable<Node> placeholderParents
	
	new(Node placeholdedNode) {
		node = placeholdedNode
	}
	
	override init() {
		placeholderParents = 
			model.getAllNodesWithAnnotation(Constants.PROJECT_ANNOTATION)
			.filter[cont | node.containingContainers.toSet.contains(cont)]
	}
	
	override getTargetFileName() 
		'''«Constants.getPostCreateHookClassName(node)».java'''
	
	override template() '''
		package «package»;
		import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook;
		
		import graphmodel.ModelElementContainer;
		import graphmodel.Node;
		
		«FOR element : #{node} + placeholderParents.filter[it != node]»
			import «model.package».«model.name.toLowerCase».«element.getName()»;
		«ENDFOR»
		public class «Constants.getPostCreateHookClassName(node)» extends CincoPostCreateHook<«node.getName()»>{
			@Override
			public void postCreate(«node.getName()» modelElement){
				ModelElementContainer target = modelElement.getContainer();
				«new CommonPartTemplate().takePlace(placeholderParents)»
			}
		}
	'''
	
}