

package de.jabc.cinco.meta.core.mgl.adapters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import mgl.Edge;
import mgl.EdgeElementConnection;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Node;
import mgl.NodeContainer;

import org.eclipse.emf.common.util.EList;

import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;
import de.metaframe.jabc.framework.sib.parameter.ContextKey.Scope;
import de.metaframe.jabc.framework.sib.parameter.foundation.ContextKeyFoundation;
import de.metaframe.jabc.framework.sib.parameter.foundation.ListBoxFoundation;

public class LightweightServiceAdapter {
	
	private enum Direction{
		INCOMING,
		OUTGOING
	}
	
	public static String findElementTypes(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation graphModelFoundation,
			ContextKeyFoundation incomingElementTypesFoundation, ListBoxFoundation listBox) {
		
		LightweightExecutionContext localContext = env.getLocalContext();
		
		try{
			GraphModel graphModel = null;
			
			switch(Scope.valueOf(graphModelFoundation.getScope())){
			case GLOBAL: graphModel = (GraphModel) localContext.getGlobalContext().get(
					graphModelFoundation); break;
			case PARENT : graphModel = (GraphModel) localContext.getParent().get(
					graphModelFoundation);break;
			default: graphModel = (GraphModel) localContext
					.get(graphModelFoundation);break;
			}
			HashMap<Edge,GraphicalModelElement> elementTypes = null;
			String direction = listBox.getSelectedValue().toString();
			elementTypes = getElementTypes(graphModel,direction);
			
			
			switch(Scope.valueOf(incomingElementTypesFoundation.getScope())){
			case GLOBAL: localContext.getGlobalContext().put(incomingElementTypesFoundation, elementTypes);break;
			case PARENT: localContext.getParent().put(incomingElementTypesFoundation,elementTypes);break;
			default: localContext.put(incomingElementTypesFoundation,elementTypes);break;
			
			}
			
		}catch(Exception e){
			localContext.getGlobalContext().put("exception", new RuntimeException(e));
			return "error";
		}
		return "default";
	}

	private static HashMap<Edge,GraphicalModelElement> getElementTypes(GraphModel gm,
			String direction) {
		
		HashMap<Edge,HashSet<GraphicalModelElement>> elementTypes = new HashMap<Edge,HashSet<GraphicalModelElement>>();
		for(Edge edge: gm.getEdges()){
			elementTypes.put(edge,new HashSet<GraphicalModelElement>());
		}
		
		for(Node node: gm.getNodes()){
			HashSet<Edge> edges = getEdgesTypes(node,Direction.valueOf(direction),gm.getEdges());
			for(Edge edge :edges){
				elementTypes.get(edge).add(node);
			}
		}
		
		for(NodeContainer container: gm.getNodeContainers()){
			HashSet<Edge> edges = getEdgesTypes(container,Direction.valueOf(direction),gm.getEdges());
			for(Edge edge :edges){
				elementTypes.get(edge).add(container);
			}
		}
		
		HashMap<Edge,GraphicalModelElement> elemTypes = new HashMap<Edge,GraphicalModelElement>();
		for(Edge edge: elementTypes.keySet()){
			
			if(elementTypes.get(edge).size()==1)
				elemTypes.put(edge, (GraphicalModelElement) ((HashSet)elementTypes.get(edge)).toArray()[0]);
			else
				elemTypes.put(edge,null);
			
		}
		
		return elemTypes;
	}

	private static HashSet<Edge> getEdgesTypes(GraphicalModelElement element, Direction direction,
			EList<Edge> graphModelEdges) {
		ArrayList<EdgeElementConnection> connections = new ArrayList<EdgeElementConnection>(); 
		switch(direction){
			case INCOMING: connections.addAll(element.getIncomingEdgeConnections()); break;
			case OUTGOING: connections.addAll(element.getOutgoingEdgeConnections());break;
		}
		
		HashSet<Edge> edges = new HashSet<Edge>();
		for(EdgeElementConnection connection: connections){
			if(connection.getConnectingEdges()!= null && !(connection.getConnectingEdges().isEmpty())){
				edges.addAll(connection.getConnectingEdges());
			}else{
				edges.addAll(graphModelEdges);
			}
				
				
		}
		return edges;
	}

}
