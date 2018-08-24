package de.jabc.cinco.meta.plugin.stack.template.file

import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import de.jabc.cinco.meta.plugin.stack.Constants
import mgl.Node
import mgl.NodeContainer

class CommonPartTemplate {

	protected extension GraphModelExtension = new GraphModelExtension

	def isCardTemplate(Node node) '''
		private boolean isCard(ModelElementContainer target) {
			«IF node instanceof NodeContainer»
				«FOR element : node.containableNodes.filter[annotations.exists[name == Constants.PROJECT_ANNOTATION]]»
					if(target instanceof «element.getName»){
						return true;
					}
				«ENDFOR»
			«ENDIF»
			return false;
		}
	'''

}
