package de.jabc.cinco.meta.plugin.papyrus.model;

import de.jabc.cinco.meta.plugin.papyrus.utils.ModelParser;

public class StyledEdge extends StyledModelElement{
	private StyledConnector sourceConnector, targetConnector;
	
	public StyledEdge(){
		sourceConnector = ModelParser.getDefaultConnector();
		targetConnector = ModelParser.getDefaultConnector();
		
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
