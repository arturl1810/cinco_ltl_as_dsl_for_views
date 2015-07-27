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

class RemoveMessageParser implements Templateable{
	
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
public class RemoveMessageParser {

    public static JSONObject removeElement(String jsonString,C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»){
        JSONObject receivedMessage = MessageParser.parse(jsonString);
        long dywaId = Long.parseLong("" + ((JSONObject) receivedMessage.get("element")).get("cinco_id"));
        «FOR StyledEdge sn:edges»
        if(receivedMessage.get("name").equals("«sn.modelElement.name.toFirstUpper»")) {
		    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = c«graphModel.name.toFirstUpper».getC«sn.modelElement.name.toFirstUpper»(dywaId);
		    if(c«sn.modelElement.name.toFirstUpper» == null){
                return getRemoveErrorResponse((JSONObject) receivedMessage.get("element"));
            }
		    boolean valid = c«sn.modelElement.name.toFirstUpper».delete();
		    return getRemoveResponse(valid,dywaId,(JSONObject) receivedMessage.get("element"));
		}
        «ENDFOR»
		«FOR StyledNode sn:nodes»
		if(receivedMessage.get("name").equals("«sn.modelElement.name.toFirstUpper»")) {
		    C«sn.modelElement.name.toFirstUpper» c«sn.modelElement.name.toFirstUpper» = c«graphModel.name.toFirstUpper».getC«sn.modelElement.name.toFirstUpper»(dywaId);
		    if(c«sn.modelElement.name.toFirstUpper» == null){
                return getRemoveErrorResponse((JSONObject) receivedMessage.get("element"));
            }
		    boolean valid = c«sn.modelElement.name.toFirstUpper».delete();
		    return getRemoveResponse(valid,dywaId,(JSONObject) receivedMessage.get("element"));
		}
        «ENDFOR»
        return getRemoveErrorResponse((JSONObject) receivedMessage.get("element"));
    }

    private static JSONObject getResponse() {
        JSONObject response = new JSONObject();
        return response;
    }

    private static JSONObject getRemoveResponse(boolean valid,long id,JSONObject element) {
        JSONObject response = getResponse();
        response.put("valid",valid);
        response.put("dywaId",id);
        response.put("muId",(String) element.get("id"));
        return response;
    }

    private static JSONObject getRemoveErrorResponse(JSONObject element) {
        JSONObject response = getResponse();
        response.put("valid",false);
        response.put("muId",(String) element.get("id"));
        return response;
    }
}
	
	'''
	
	
	
}