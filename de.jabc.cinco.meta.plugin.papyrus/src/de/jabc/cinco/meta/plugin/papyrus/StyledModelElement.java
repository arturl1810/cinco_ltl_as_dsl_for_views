package de.jabc.cinco.meta.plugin.papyrus;

import style.Style;
import mgl.GraphicalModelElement;

public class StyledModelElement {
	private GraphicalModelElement modelElement;
	private Style modelStyle;
	
	public StyledModelElement(){
		
	}
	
	public StyledModelElement(GraphicalModelElement modelElement) {
		this.modelElement = modelElement;
	}
	
	public StyledModelElement(Style modelStyle) {
		this.modelStyle = modelStyle;
	}
	
	public StyledModelElement(GraphicalModelElement modelElement, Style modelStyle) {
		this.modelElement = modelElement;
		this.modelStyle = modelStyle;
	}
	
	public StyledModelElement(Style modelStyle, GraphicalModelElement modelElement) {
		this.modelElement = modelElement;
		this.modelStyle = modelStyle;
	}

	public GraphicalModelElement getModelElement() {
		return modelElement;
	}

	public void setModelElement(GraphicalModelElement modelElement) {
		this.modelElement = modelElement;
	}

	public Style getModelStyle() {
		return modelStyle;
	}

	public void setModelStyle(Style modelStyle) {
		this.modelStyle = modelStyle;
	}
	
	
	
}
