package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;
import java.util.HashMap;

import mgl.GraphModel;
import mgl.Type;

public class TemplateContainer {
	private GraphModel graphModel;
	private ArrayList<StyledNode> nodes;
	private ArrayList<StyledEdge> edges;
	private ArrayList<Type> enums;
	private HashMap<String,ArrayList<StyledNode>> groupedNodes;
	private ArrayList<ConnectionConstraint> validConnections;
	ArrayList<EmbeddingConstraint> embeddingConstraints;
	
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
	public ArrayList<EmbeddingConstraint> getEmbeddingConstraints() {
		return embeddingConstraints;
	}
	public void setEmbeddingConstraints(
			ArrayList<EmbeddingConstraint> embeddingConstraints) {
		this.embeddingConstraints = embeddingConstraints;
	}
	public ArrayList<Type> getEnums() {
		return enums;
	}
	public void setEnums(ArrayList<Type> enums) {
		this.enums = enums;
	}
	
	
	
	
}
