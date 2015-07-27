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

class RotateMessageParser implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums)
	'''
package de.ls5.cinco.message;

import de.ls5.cinco.transformation.api.*;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONArray;
import org.json.simple.parser.ParseException;

/**
 * Generated by Pyro CINCO Meta plugin
 */
public class RotateMessageParser {

    public static JSONObject rotateElement(String jsonString,C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»){
        JSONObject receivedMessage = MessageParser.parse(jsonString);
        JSONObject element = (JSONObject) receivedMessage.get("element");
        long elementId = Long.parseLong("" + element.get("cinco_id"));
        double angle = Double.parseDouble("" + element.get("angle"));
        
		«FOR StyledNode sn:nodes»
		if(receivedMessage.get("name").equals("«sn.modelElement.name.toFirstUpper»")) {
		    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = c«graphModel.name.toFirstUpper».getC«sn.modelElement.name.toFirstUpper»(elementId);
		    if(c«sn.modelElement.name.toFirstUpper» == null){
                return getRotateErrorResponse((JSONObject) receivedMessage.get("element"));
            }
		    c«sn.modelElement.name.toFirstUpper».setAngle(angle);
		    return getRotateResponse(true,c«sn.modelElement.name.toFirstUpper».getModelElement().getId(),(JSONObject) receivedMessage.get("element"));
		}
        «ENDFOR»
        return getRotateErrorResponse((JSONObject) receivedMessage.get("element"));
    }
    
    private static JSONObject getResponse() {
        JSONObject response = new JSONObject();
        return response;
    }

    private static JSONObject getRotateResponse(boolean valid,long id,JSONObject element) {
        JSONObject response = getResponse();
        response.put("valid",valid);
        response.put("dywaId",id);
        response.put("muId",(String) element.get("id"));
        return response;
    }

    private static JSONObject getRotateErrorResponse(JSONObject element) {
        JSONObject response = getResponse();
        response.put("valid",false);
        response.put("muId",(String) element.get("id"));
        return response;
    }
}
	
	'''
	
}