package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import java.util.ArrayList
import java.util.HashMap
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.GraphModel
import mgl.PrimitiveAttribute
import mgl.Type
import org.eclipse.emf.ecore.EPackage

interface Templateable {
	 def CharSequence create(GraphModel graphModel,ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String,ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections,ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores);
	 
	 static def getType(Attribute attr) {
	 	switch attr {
	 		ComplexAttribute : attr.type.name
	 		PrimitiveAttribute : attr.type.getName
	 	}
	 }
}