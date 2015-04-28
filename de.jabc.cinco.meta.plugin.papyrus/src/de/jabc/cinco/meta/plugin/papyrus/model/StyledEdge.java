package de.jabc.cinco.meta.plugin.papyrus.model;

public class StyledEdge extends StyledModelElement{
	private double labelLocation;
	private StyledConnector sourceConnector, targetConnector;
	public double getLabelLocation() {
		return labelLocation;
	}
	public void setLabelLocation(double labelLocation) {
		this.labelLocation = labelLocation;
	}
	public StyledConnector getSourceConnector() {
		return sourceConnector;
	}
	public void setSourceConnector(StyledConnector sourceConnector) {
		this.sourceConnector = sourceConnector;
	}
	public StyledConnector getTargetConnector() {
		return targetConnector;
	}
	public void setTargetConnector(StyledConnector targetConnector) {
		this.targetConnector = targetConnector;
	}
	
	
}
