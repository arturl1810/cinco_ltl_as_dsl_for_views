package de.jabc.cinco.meta.plugin.papyrus.model;

public class ConnectionConstraint {
	private StyledNode sourceNode, targetNode;
	private StyledEdge connectingEdge;
	private int cardinality;
	public StyledNode getSourceNode() {
		return sourceNode;
	}
	public void setSourceNode(StyledNode sourceNode) {
		this.sourceNode = sourceNode;
	}
	public StyledNode getTargetNode() {
		return targetNode;
	}
	public void setTargetNode(StyledNode targetNode) {
		this.targetNode = targetNode;
	}
	public StyledEdge getConnectingEdge() {
		return connectingEdge;
	}
	public void setConnectingEdge(StyledEdge connectingEdge) {
		this.connectingEdge = connectingEdge;
	}
	public int getCardinality() {
		return cardinality;
	}
	public void setCardinality(int cardinality) {
		this.cardinality = cardinality;
	}
	
	
}
