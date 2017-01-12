package de.jabc.cinco.meta.plugin.pyro.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.ecore.EPackage;

import mgl.GraphModel;
import mgl.Type;

public class TemplateContainer {
	private GraphModel graphModel;
	private Set<GraphModel> graphModels;
	private List<EPackage> ecores;
	private List<StyledNode> nodes;
	private List<StyledEdge> edges;
	private List<Type> enums;
	private HashMap<String,List<StyledNode>> groupedNodes;
	private List<ConnectionConstraint> validConnections;
	List<EmbeddingConstraint> embeddingConstraints;
	
	public GraphModel getGraphModel() {
		return graphModel;
	}
	public void setGraphModel(GraphModel graphModel) {
		this.graphModel = graphModel;
	}
	
	public List<StyledNode> getNodes() {
		return nodes;
	}
	public void setNodes(List<StyledNode> nodes) {
		this.nodes = nodes;
	}
	public List<StyledEdge> getEdges() {
		return edges;
	}
	public void setEdges(List<StyledEdge> edges) {
		this.edges = edges;
	}
	public HashMap<String, List<StyledNode>> getGroupedNodes() {
		return groupedNodes;
	}
	public void setGroupedNodes(HashMap<String, List<StyledNode>> groupedNodes) {
		this.groupedNodes = groupedNodes;
	}
	public List<ConnectionConstraint> getValidConnections() {
		return validConnections;
	}
	public void setValidConnections(List<ConnectionConstraint> validConnections) {
		this.validConnections = validConnections;
	}
	public List<EmbeddingConstraint> getEmbeddingConstraints() {
		return embeddingConstraints;
	}
	public void setEmbeddingConstraints(
			List<EmbeddingConstraint> embeddingConstraints) {
		this.embeddingConstraints = embeddingConstraints;
	}
	public List<Type> getEnums() {
		return enums;
	}
	public void setEnums(List<Type> enums) {
		this.enums = enums;
	}
	public Set<GraphModel> getGraphModels() {
		return graphModels;
	}
	public void setGraphModels(Set<GraphModel> graphModels) {
		this.graphModels = graphModels;
	}
	public List<EPackage> getEcores() {
		return ecores;
	}
	public void setEcores(List<EPackage> ecores) {
		this.ecores = ecores;
	}
	
	
	
	
}
