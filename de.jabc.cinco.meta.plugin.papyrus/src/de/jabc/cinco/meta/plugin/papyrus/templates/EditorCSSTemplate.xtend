package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint

class EditorCSSTemplate implements Templateable{

	
	def createNodeCSS(StyledNode styledNode)
	'''
		.devs.«styledNode.modelElement.name.toFirstUpper» .label{
		    font-size: «styledNode.styledLabel.labelFontSize»px;
		    font-family: «styledNode.styledLabel.fontName», 'Lucida Sans Unicode', sans-serif
		}
	'''
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections)
	'''
		/* CSS for Nodes */
		«FOR StyledNode node : nodes»
		«IF node.styledLabel != null»
		«createNodeCSS(node)»
		«ENDIF»
		«ENDFOR»
	'''
	
}