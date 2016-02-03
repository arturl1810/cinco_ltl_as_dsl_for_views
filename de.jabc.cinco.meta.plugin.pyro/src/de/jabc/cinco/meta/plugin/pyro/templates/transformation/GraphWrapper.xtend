package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphicalModelElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class GraphWrapper implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
	package de.ls5.cinco.pyro.transformation.api.«graphModel.name.toFirstLower»;
	
	import de.ls5.dywa.generated.entity.*;
	
	import java.util.ArrayList;
	import java.util.List;
	
	/**
	 * Created by Pyro CINCO Meta Plugin.
	 */
	public interface C«graphModel.name.toFirstUpper»Wrapper {
	    public C«graphModel.name.toFirstUpper» wrap«graphModel.name.toFirstUpper»(«graphModel.name.toFirstUpper» «graphModel.name.toFirstLower»);
	}
	'''
}
