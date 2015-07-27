package de.jabc.cinco.meta.plugin.pyro.model;

public class ConnectionConstraint {
	private StyledNode sourceNode, targetNode;
	private StyledEdge connectingEdge;
	private int sourceCardinalityLow,sourceCardinalityHigh, targetCardinalityLow, targetCardinalityHigh;
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
	public int getSourceCardinalityLow() {
		return sourceCardinalityLow;
	}
	public void setSourceCardinalityLow(int sourceCardinalityLow) {
		this.sourceCardinalityLow = sourceCardinalityLow;
	}
	public int getSourceCardinalityHigh() {
		return sourceCardinalityHigh;
	}
	public void setSourceCardinalityHigh(int sourceCardinalityHigh) {
		this.sourceCardinalityHigh = sourceCardinalityHigh;
	}
	public int getTargetCardinalityLow() {
		return targetCardinalityLow;
	}
	public void setTargetCardinalityLow(int targetCardinalityLow) {
		this.targetCardinalityLow = targetCardinalityLow;
	}
	public int getTargetCardinalityHigh() {
		return targetCardinalityHigh;
	}
	public void setTargetCardinalityHigh(int targetCardinalityHigh) {
		this.targetCardinalityHigh = targetCardinalityHigh;
	}
	
	public String toString() {
		String out =  sourceNode.getModelElement()!=null ? sourceNode.getModelElement().getName():"null";
		out += " - " + sourceCardinalityLow + ".." + sourceCardinalityHigh + " - ";
		out += connectingEdge.getModelElement()!=null ? connectingEdge.getModelElement().getName():"null";
		out += " - " + targetCardinalityLow + ".." + targetCardinalityHigh + " - ";
		out += targetNode.getModelElement()!=null ? targetNode.getModelElement().getName():"null";
		return out;
	}
	
	
	
}
