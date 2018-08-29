package de.jabc.cinco.meta.plugin.stack.template.file

import de.jabc.cinco.meta.plugin.stack.Constants
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node
import mgl.NodeContainer

class PostMoveTemplate extends FileTemplate {

	Node node

	new(Node stackableNode) {
		node = stackableNode
	}

	override getTargetFileName() '''«Constants.getPostMoveHookClassName(node)».java'''

	override template() '''
		package «package»;
		import de.jabc.cinco.meta.runtime.hook.CincoPostMoveHook;
				
		import graphmodel.Container;
		import graphmodel.ModelElementContainer;
		
		«IF node instanceof NodeContainer»
			«FOR element : #{node} + node.containableNodes.filter[annotations.exists[name == Constants.PROJECT_ANNOTATION]].filter[it != node]»
				import «model.package».«model.name.toLowerCase».«element.getName()»;
			«ENDFOR»
		«ENDIF»
		«IF !(node instanceof NodeContainer)»
			import «model.package».«model.name.toLowerCase».«node.getName()»;
		«ENDIF»
		
		public class «Constants.getPostMoveHookClassName(node)» extends CincoPostMoveHook<«node.getName()»>{
			@Override
			public void postMove(«node.getName()» modelElement, ModelElementContainer source,
					ModelElementContainer target, int x, int y, int deltaX, int deltaY) {
				if(isCard(target) && target instanceof Container){
					int xPos = ((Container)target).getX();
					int yPos = ((Container)target).getY();
					if(target instanceof Container){
						ModelElementContainer newParent = ((Container) target).getContainer();
						if(modelElement.canMoveTo(newParent)){
							modelElement.moveTo(newParent, xPos, yPos);
						}else
						{
							if(modelElement.canMoveTo(source)){
								modelElement.moveTo(source, deltaX, deltaY);
							}
						}
					}
				}
			}
			«new CommonPartTemplate().isCardTemplate(node)»
		}
	'''
}
