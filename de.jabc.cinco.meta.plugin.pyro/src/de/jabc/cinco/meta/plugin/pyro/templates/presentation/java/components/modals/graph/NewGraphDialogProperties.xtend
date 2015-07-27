package de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph

import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type

class NewGraphDialogProperties implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
buttonText=Create «graphModel.name.toFirstUpper»
modalTitle=Create a new «graphModel.name.toFirstUpper»
NameLabel=Name
GraphLabel=«graphModel.name.toFirstUpper»
create=Create
cancel=Cancel
	'''
	
}