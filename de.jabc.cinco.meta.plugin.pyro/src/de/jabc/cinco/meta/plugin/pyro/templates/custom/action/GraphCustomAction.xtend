package de.jabc.cinco.meta.plugin.pyro.templates.custom.action

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import de.jabc.cinco.meta.plugin.pyro.templates.AnnotationElementTemplateable

class GraphCustomAction implements AnnotationElementTemplateable {
	
	override create(mgl.Annotation annotation,StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.custom.action.«graphModel.name.toFirstLower»;

import de.ls5.cinco.custom.feature.CincoCustomAction;
import de.ls5.cinco.transformation.api.«graphModel.name.toFirstLower».C«graphModel.name.toFirstUpper»;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public class «ModelParser.getCustomActionName(annotation).toFirstUpper»CustomAction extends CincoCustomAction<C«graphModel.name.toFirstUpper»>{
    @Override
    public boolean canExecute(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper») {
        return true;
    }

    @Override
    public void execute(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper») {
    }

    @Override
    public String getName() {
        return "HotFuzz";
    }
}

	'''
	
}