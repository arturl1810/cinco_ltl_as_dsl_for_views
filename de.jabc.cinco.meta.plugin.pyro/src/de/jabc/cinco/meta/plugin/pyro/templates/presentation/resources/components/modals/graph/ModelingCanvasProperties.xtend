package de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class ModelingCanvasProperties implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
	buttonText=Create GraphModel
	modalTitle=Create a new GraphModel
	NameLabel=Name
	GraphLabel=Graph
	create=Create
	cancel=Cancel
	
	graphView=Canvas
	map=Map
	propertiesView= Properties View
	
	buttonRemove=Remove
	buttonRotate=Rotate
	buttonResize=Scale
	'''
	
}