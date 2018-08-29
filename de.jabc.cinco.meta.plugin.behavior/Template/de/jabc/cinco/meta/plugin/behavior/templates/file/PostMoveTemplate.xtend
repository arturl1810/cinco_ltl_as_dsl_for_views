package de.jabc.cinco.meta.plugin.behavior.templates.file

import de.jabc.cinco.meta.plugin.behavior.Constants
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node
import mgl.NodeContainer

class PostMoveTemplate extends FileTemplate {

	Node node

	new(Node placeholdedNode) {
		node = placeholdedNode
	}

	override getTargetFileName() '''«Constants.getPostMoveHookClassName(node)».java'''

	override template() '''package «package»;
		import de.jabc.cinco.meta.runtime.hook.CincoPostMoveHook;
		
		import graphmodel.ModelElementContainer;
		import «model.package».«model.name.toLowerCase».«node.getName()»;
		«FOR element : getContainingContainersWithAnnotation»
			import «model.package».«model.name.toLowerCase».«element.getName()»;
		«ENDFOR»
		public class «node.getName()»PostMoveHook extends CincoPostMoveHook<«node.getName()»>{
			@Override
			public void postMove(«node.getName()» modelElement, ModelElementContainer source,
						ModelElementContainer target, int x, int y, int deltaX, int deltaY){
				if(target == source){
					return;
				}
				«FOR element : getContainingContainersWithAnnotation»
					«FOR annot : element.annotations.filter[n | n.name.equals(Constants.PROJECT_ANNOTATION)]»
						if(target instanceof «element.name»){
							new «annot.value.get(0)»().hasEntered(modelElement, («element.name»)target);
						}
						if(source instanceof «element.name»){
							 new «annot.value.get(0)»().hasLeft(modelElement, («element.name»)source);
						}
					«ENDFOR»
				«ENDFOR»
			}
		}
	'''

	def Iterable<NodeContainer> getContainingContainersWithAnnotation() {
		node.containingContainers.filter[n|n.hasAnnotation(Constants.PROJECT_ANNOTATION)]
	}
}
