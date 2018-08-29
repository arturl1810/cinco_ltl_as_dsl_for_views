package de.jabc.cinco.meta.plugin.behavior.templates.file

import de.jabc.cinco.meta.plugin.behavior.Constants
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node
import mgl.NodeContainer

class PostCreateTemplate extends FileTemplate {

	Node node

	new(Node node) {
		this.node = node
	}

	override getTargetFileName() '''«Constants.getPostCreateHookClassName(node)».java'''

	override template() '''
		package «package»;
		import de.jabc.cinco.meta.runtime.hook.CincoPostCreateHook;
		
		import graphmodel.ModelElementContainer;
		import «model.package».«model.name.toLowerCase».«node.getName()»;
		«FOR element : getContainingContainersWithAnnotation»
			import «model.package».«model.name.toLowerCase».«element.getName()»;
		«ENDFOR»
		public class «node.getName()»PostCreateHook extends CincoPostCreateHook<«node.getName()»>{
			@Override
			public void postCreate(«node.getName()» modelElement){
				ModelElementContainer target = modelElement.getContainer();
				«FOR element : getContainingContainersWithAnnotation»
					«FOR annot : element.annotations.filter[n | n.name.equals(Constants.PROJECT_ANNOTATION)]»
						if(target instanceof «element.name»){
							new «annot.value.get(0)»().hasEntered(modelElement, («element.name»)target);
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
