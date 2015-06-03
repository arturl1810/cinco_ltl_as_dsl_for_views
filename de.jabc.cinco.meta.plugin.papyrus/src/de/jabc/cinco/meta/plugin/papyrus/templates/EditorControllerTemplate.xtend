package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.papyrus.model.EmbeddingConstraint
import mgl.Type

class EditorControllerTemplate implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	

	
}