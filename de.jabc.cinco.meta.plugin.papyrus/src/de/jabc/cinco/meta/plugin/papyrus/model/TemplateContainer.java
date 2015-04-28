package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;
import java.util.HashMap;

import mgl.GraphModel;

public class TemplateContainer {
	private GraphModel graphModel;
	private ArrayList<StyledNode> nodes;
	private ArrayList<StyledEdge> edges;
	private HashMap<String,ArrayList<StyledNode>> groupedNodes;
	private ArrayList<ConnectionConstraint> validConnections;
	
	public GraphModel getGraphModel() {
		return graphModel;
	}
	public void setGraphModel(GraphModel graphModel) {
		this.graphModel = graphModel;
	}
	
	public ArrayList<StyledNode> getNodes() {
		return nodes;
	}
	public void setNodes(ArrayList<StyledNode> nodes) {
		this.nodes = nodes;
	}
	public ArrayList<StyledEdge> getEdges() {
		return edges;
	}
	public void setEdges(ArrayList<StyledEdge> edges) {
		this.edges = edges;
	}
	public HashMap<String, ArrayList<StyledNode>> getGroupedNodes() {
		return groupedNodes;
	}
	public void setGroupedNodes(HashMap<String, ArrayList<StyledNode>> groupedNodes) {
		this.groupedNodes = groupedNodes;
	}
	public ArrayList<ConnectionConstraint> getValidConnections() {
		return validConnections;
	}
	public void setValidConnections(ArrayList<ConnectionConstraint> validConnections) {
		this.validConnections = validConnections;
	}
	
	
}
