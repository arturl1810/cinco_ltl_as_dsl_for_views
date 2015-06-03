package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint
import java.util.HashMap
import de.jabc.cinco.meta.plugin.papyrus.model.EmbeddingConstraint
import mgl.Type

interface Templateable {
	 def CharSequence create(GraphModel graphModel,ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String,ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections,ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums);
}