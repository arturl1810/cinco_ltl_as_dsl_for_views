

package de.jabc.cinco.meta.core.mgl.adapters;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.stream.Collectors;

import mgl.Edge;
import mgl.EdgeElementConnection;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Node;
import mgl.NodeContainer;

import org.eclipse.emf.common.util.EList;

import de.jabc.cinco.meta.core.utils.InheritanceUtil;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironmentAdapter;
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
		List<NodeContainer> nodeContainers = gm.getNodes().stream().filter(n -> n instanceof NodeContainer).map(n -> (NodeContainer)n).collect(Collectors.toList());
		for(NodeContainer container: nodeContainers){
			HashSet<Edge> edges = getEdgesTypes(container,Direction.valueOf(direction),gm.getEdges());
			for(Edge edge :edges){
				elementTypes.get(edge).add(container);
			}
		}
		
		HashMap<Edge,GraphicalModelElement> elemTypes = new HashMap<Edge,GraphicalModelElement>();
		for(Edge edge: elementTypes.keySet()){
			
			if(elementTypes.get(edge).size()==1)
				elemTypes.put(edge, (GraphicalModelElement) ((HashSet)elementTypes.get(edge)).toArray()[0]);
			else if(elementTypes.get(edge).size()>1)
				//elemTypes.put(edge,null);
				elemTypes.put(edge,InheritanceUtil.getLowestMutualSuperNode(elementTypes.get(edge).stream().map(gme -> (Node)gme).collect(Collectors.toList())));
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

	public static String getAllSubTypes(
			LightweightExecutionEnvironment env,
			ContextKeyFoundation modelElementFoundation,
			ContextKeyFoundation subTypesFoundation) {
		
		try{
			LightweightExecutionContext modelElementContext = switchContext(modelElementFoundation, env);
			GraphicalModelElement modelElement = (GraphicalModelElement)modelElementContext.get(modelElementFoundation);
			ArrayList<GraphicalModelElement> subElements= new ArrayList<GraphicalModelElement>();
			if(modelElement instanceof NodeContainer){
				for(Node node: ((NodeContainer) modelElement).getGraphModel().getNodes()){
					if(node!=modelElement && getAllSuperTypes(node).contains(modelElement))
						subElements.add(node);
				}
				List<NodeContainer> nodeContainers = ((NodeContainer) modelElement).getGraphModel().getNodes().stream().filter(n -> n instanceof NodeContainer).map(n -> (NodeContainer)n).collect(Collectors.toList());
				for(NodeContainer node: nodeContainers){
					if(node!=modelElement && getAllSuperTypes(node).contains(modelElement))
						subElements.add(node);
				}
			}else if(modelElement instanceof Node){
				
				for(Node node: ((Node) modelElement).getGraphModel().getNodes()){
					if(node!=modelElement && getAllSuperTypes(node).contains(modelElement))
						subElements.add(node);
				}
				List<NodeContainer> nodeContainers = ((Node) modelElement).getGraphModel().getNodes().stream().filter(n -> n instanceof NodeContainer).map(n -> (NodeContainer)n).collect(Collectors.toList());
				for(NodeContainer node: nodeContainers){
					if(node!=modelElement && getAllSuperTypes(node).contains(modelElement))
						subElements.add(node);
				}
			
			}else if(modelElement instanceof Edge){
				for(Edge edge: ((Edge)modelElement).getGraphModel().getEdges()){
					if(edge!=modelElement && getAllSuperTypes(edge).contains(modelElement))
						subElements.add(edge);
				}
			}
			
			LightweightExecutionContext subElementsContext = switchContext(subTypesFoundation,env);
			subElementsContext.put(subTypesFoundation,subElements);
			
		}catch(Exception e){
			env.getLocalContext().getGlobalContext().put("exception", e);
			return "error";
		}
		
		
		return "default";
	}
	
	
	private static Collection<GraphicalModelElement> getAllSuperTypes(GraphicalModelElement modelElement) {
		ArrayList<GraphicalModelElement> superTypes = new ArrayList<GraphicalModelElement>();
		if(modelElement instanceof Node){
			Node node = (Node)modelElement;
			Node superNode = node.getExtends();
			while(superNode != null){
				superTypes.add(superNode);
				superNode = superNode.getExtends();
			}
		}
		if(modelElement instanceof NodeContainer){
			Node nodeContainer = (NodeContainer)modelElement;
			Node superNodeContainer = nodeContainer.getExtends();
			while(superNodeContainer != null){
				superTypes.add(superNodeContainer);
				superNodeContainer = superNodeContainer.getExtends();
			}
		}
		if(modelElement instanceof Edge){
			Edge edge = (Edge)modelElement;
			Edge superEdge = edge.getExtends();
			while(superEdge != null){
				superTypes.add(superEdge);
				superEdge = superEdge.getExtends();
			}
		}
		
		return superTypes;
	}

	public static LightweightExecutionContext switchContext(ContextKeyFoundation foundation, LightweightExecutionEnvironment env){
		LightweightExecutionContext localContext = env.getLocalContext();
		switch(Scope.valueOf(foundation.getScope())){
			case GLOBAL: return localContext.getGlobalContext();
			case PARENT : return localContext.getParent();
			default: return localContext;
		}

	}
}
