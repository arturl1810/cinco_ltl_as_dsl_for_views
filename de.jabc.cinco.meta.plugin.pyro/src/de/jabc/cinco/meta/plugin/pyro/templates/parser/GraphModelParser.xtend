package de.jabc.cinco.meta.plugin.pyro.templates.parser

import de.jabc.cinco.meta.plugin.pyro.templates.ElementTemplateable
import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import mgl.Attribute
import mgl.Node
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class GraphModelParser implements ElementTemplateable {
	
	override create(StyledModelElement sme, GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.parser;

import de.ls5.dywa.generated.entity.*;
import de.ls5.cinco.custom.action.*;
import de.ls5.cinco.transformation.api.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.text.MessageFormat;


/**
 * Generated by Pyro CINCO Meta Plugin
 */
public class «graphModel.name.toFirstUpper»Parser {

	public static String getCustomeActionsJSON()
    {
        String jsonString = "";
        «IF ModelParser.isCustomeAction(graphModel)»
        jsonString += "«graphModel.name.toFirstUpper» : [";
        «FOR String name: ModelParser.getCustomActionNames(graphModel) SEPARATOR "jsonString += \",\";"»
        «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction «ModelParser.getCustomActionName(name).toFirstLower»CustomAction = new «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction();
        jsonString += "'"+«ModelParser.getCustomActionName(name).toFirstLower»CustomAction.getName() + "'";
        «ENDFOR»
        jsonString += "]";
        jsonString += ",";
        «ENDIF»
		«FOR StyledNode sn:nodes »
		«IF ModelParser.isCustomeAction(sn.modelElement)»
		jsonString += "«sn.modelElement.name.toFirstUpper» : [";
        «FOR String name: ModelParser.getCustomActionNames(sn.modelElement) SEPARATOR "jsonString += \",\";"»
        «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction «ModelParser.getCustomActionName(name).toFirstLower»CustomAction = new «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction();
        jsonString += "'"+«ModelParser.getCustomActionName(name).toFirstLower»CustomAction.getName() + "'";
       «ENDFOR»
        jsonString += "]";
        jsonString += ",";
        «ENDIF»
		«ENDFOR»
		«FOR StyledEdge sn:edges »
		«IF ModelParser.isCustomeAction(sn.modelElement)»
		jsonString += "«sn.modelElement.name.toFirstUpper» : [";
        «FOR String name: ModelParser.getCustomActionNames(sn.modelElement) SEPARATOR "jsonString += \",\";"»
        «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction «ModelParser.getCustomActionName(name).toFirstLower»CustomAction = new «ModelParser.getCustomActionName(name).toFirstUpper»CustomAction();
        jsonString += "'"+«ModelParser.getCustomActionName(name).toFirstLower»CustomAction.getName() + "'";
       «ENDFOR»
        jsonString += "]";
        jsonString += ",";
        «ENDIF»
		«ENDFOR»
        return jsonString;
    }

    public static JSONArray toJSON(«graphModel.name.toFirstUpper» «graphModel.name.toFirstLower») {
        JSONArray «graphModel.name.toFirstLower»Attributes = new JSONArray();
        
        //Attributes
        «FOR Attribute attribute:graphModel.attributes»
        «AttributeParser.createAttribute(attribute,graphModel.name,enums)»
        «ENDFOR»
        return «graphModel.name.toFirstLower»Attributes;
    }

    public static String toJSONString(C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper») {
    	String jsonPostString = "";
        String jsonPreString =
                "cinco_graphModelAttr = {0};\n";
        jsonPreString = MessageFormat.format(jsonPreString,toJSON((«graphModel.name.toFirstUpper»)c«graphModel.name.toFirstUpper».getGraphModel()).toJSONString());
        for(CModelElement cModelElement:c«graphModel.name.toFirstUpper».getModelElements()){
        	«FOR StyledNode sn:nodes»
        	«IF sn.modelElement instanceof Node»
        	if(cModelElement.getModelElement() instanceof «sn.modelElement.name.toFirstUpper»){
                jsonPreString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPreString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                jsonPostString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPostString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                continue;
            }
            «ENDIF»
        	«ENDFOR»
        	«FOR StyledNode sn:nodes»
        	«IF !(sn.modelElement instanceof Node)»
        	if(cModelElement.getModelElement() instanceof «sn.modelElement.name.toFirstUpper»){
                jsonPreString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPreString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                jsonPostString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPostString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                continue;
            }
            «ENDIF»
        	«ENDFOR»
        	«FOR StyledEdge sn:edges»
        	if(cModelElement.getModelElement() instanceof «sn.modelElement.name.toFirstUpper»){
                jsonPreString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPreString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                jsonPostString += «sn.modelElement.name.toFirstUpper»Parser.toJSONPostString((«sn.modelElement.name.toFirstUpper»)cModelElement.getModelElement());
                continue;
            }
        	«ENDFOR»
        }
        return jsonPreString + jsonPostString;
    }

}
	
	'''
	
}