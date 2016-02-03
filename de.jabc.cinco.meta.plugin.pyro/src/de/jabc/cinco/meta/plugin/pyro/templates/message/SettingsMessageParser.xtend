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
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class SettingsMessageParser implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
package de.ls5.cinco.pyro.message.«graphModel.name.toFirstLower»;

import de.ls5.cinco.pyro.message.MessageParser;
import de.ls5.cinco.pyro.transformation.api.«graphModel.name.toFirstLower».C«graphModel.name.toFirstUpper»;
import de.ls5.dywa.generated.entity.«graphModel.name.toFirstUpper»;
import org.json.simple.JSONObject;

/**
 * Generated by Pyro CINCO Meta plugin
 */
public class SettingsMessageParser {
    public static JSONObject changeSettings(String jsonString,C«graphModel.name.toFirstUpper» c«graphModel.name.toFirstUpper»){
        JSONObject receivedMessage = MessageParser.parse(jsonString);
        «graphModel.name.toFirstUpper» «graphModel.name.toFirstLower» = («graphModel.name.toFirstUpper») c«graphModel.name.toFirstUpper».getGraphModel();
        «graphModel.name.toFirstLower».setscaleFactor(Double.parseDouble(""+receivedMessage.get("scaleFactor")));
        «graphModel.name.toFirstLower».settheme(""+receivedMessage.get("theme"));
        «graphModel.name.toFirstLower».setedgeTriggerWidth(Double.parseDouble("" + receivedMessage.get("edgeTriggerWidth")));
        «graphModel.name.toFirstLower».setsnapRadius(Double.parseDouble("" + receivedMessage.get("snapRadius")));
        «graphModel.name.toFirstLower».setpaperWidth(Double.parseDouble("" + receivedMessage.get("paperWidth")));
        «graphModel.name.toFirstLower».setpaperHeight(Double.parseDouble("" + receivedMessage.get("paperHeight")));
        «graphModel.name.toFirstLower».setgridSize(Double.parseDouble("" + receivedMessage.get("gridSize")));
        «graphModel.name.toFirstLower».setresizeStep(Double.parseDouble("" + receivedMessage.get("resizeStep")));
        «graphModel.name.toFirstLower».setrotateStep(Double.parseDouble("" + receivedMessage.get("rotateStep")));
        JSONObject edgeStyleMode = (JSONObject) receivedMessage.get("edgeStyleMode");
        «graphModel.name.toFirstLower».setedgeStyleModeConnector("" + edgeStyleMode.get("connector"));
        «graphModel.name.toFirstLower».setedgeStyleModeRouter("" + edgeStyleMode.get("router"));
        «graphModel.name.toFirstLower».setminimizedMenu(Boolean.parseBoolean(""+receivedMessage.get("minimizedMenu")));
        «graphModel.name.toFirstLower».setminimizedGraph(Boolean.parseBoolean("" + receivedMessage.get("minimizedGraph")));
        «graphModel.name.toFirstLower».setminimizedMap(Boolean.parseBoolean(""+receivedMessage.get("minimizedMap")));

        return getChangeSettingsResponse(true,jsonString);
    }

    private static JSONObject getResponse() {
        return new JSONObject();
    }

    private static JSONObject getChangeSettingsResponse(boolean valid,String element) {
        JSONObject response = getResponse();
        response.put("valid",valid);
        response.put("settings",element);
        return response;
    }
}
'''
	
	
	
}