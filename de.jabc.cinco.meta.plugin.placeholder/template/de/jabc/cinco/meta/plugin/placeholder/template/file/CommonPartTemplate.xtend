package de.jabc.cinco.meta.plugin.placeholder.template.file

import mgl.Node

class CommonPartTemplate {
	def takePlace (Iterable<Node> placeholderParents) {
		'''
			«FOR element :placeholderParents BEFORE "if(" SEPARATOR "||" AFTER "){"»target instanceof «element.name»«ENDFOR»
				modelElement.resize(((Node) target).getWidth(), ((Node) target).getHeight());
					if(modelElement.getX() != 0 || modelElement.getY() !=0){
						modelElement.move(0, 0);
					}
			}
		'''
	}
}