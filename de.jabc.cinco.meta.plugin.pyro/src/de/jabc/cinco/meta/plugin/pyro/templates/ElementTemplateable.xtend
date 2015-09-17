package de.jabc.cinco.meta.plugin.pyro.templates

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement

interface ElementTemplateable {
	 def CharSequence create(StyledModelElement sme,GraphModel graphModel,ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String,ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections,ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums);
}