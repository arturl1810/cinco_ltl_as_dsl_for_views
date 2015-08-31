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
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class NewGraphDialogProperties implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
buttonText=Create GraphModel
modalTitle=Create a new GraphModel
NameLabel=Name
GraphLabel=GraphModel
create=Create
cancel=Cancel
	'''
	
}