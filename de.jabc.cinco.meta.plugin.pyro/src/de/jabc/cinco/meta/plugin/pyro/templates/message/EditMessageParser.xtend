package de.jabc.cinco.meta.plugin.pyro.templates.message

import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type

class EditMessageParser implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.message;

import de.ls5.cinco.transformation.api.*;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Generated by Pyro CINCO Meta plugin
 */
public class EditMessageParser {
    public static JSONObject editElement(String jsonString,C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»){
        JSONObject receivedMessage = MessageParser.parse(jsonString);
        String option = (String) receivedMessage.get("option");
        if(option.equals("attribute")){
            return AttributeMessageParser.attributeElement(jsonString,c«graphModel.name.toFirstUpper»);
        }
        JSONObject element = (JSONObject) receivedMessage.get("element");
        
        if(option.equals("move")){
            return MoveMessageParser.moveElement(jsonString,c«graphModel.name.toFirstUpper»);
        }
        if(option.equals("resize")){
            return ResizeMessageParser.resizeElement(jsonString,c«graphModel.name.toFirstUpper»);
        }
        if(option.equals("rotate")){
            return RotateMessageParser.rotateElement(jsonString,c«graphModel.name.toFirstUpper»);
        }
        return getEditErrorResponse(element);
    }

    private static JSONObject getResponse() {
        return new JSONObject();
    }

    private static JSONObject getEditErrorResponse(JSONObject element) {
        JSONObject response = getResponse();
        response.put("valid",false);
        response.put("muId",(String) element.get("id"));
        return response;
    }
}
	
	'''
	
}