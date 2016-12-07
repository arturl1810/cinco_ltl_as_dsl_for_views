package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer

class EditorCSSTemplate implements Templateable{

	
	def createNodeCSS(StyledNode styledNode)
	'''
		.devs.«styledNode.modelElement.name.toFirstUpper» .label{
		    font-size: «styledNode.styledLabel.labelFontSize»px;
		    font-family: «styledNode.styledLabel.fontName», 'Lucida Sans Unicode', sans-serif
		}
	'''
	
	override create(TemplateContainer tc)
	'''
		/* CSS for Nodes */
		«FOR StyledNode node : tc.nodes.filter[node|node.styledLabel != null]»
			«createNodeCSS(node)»
		«ENDFOR»
	'''
	
}