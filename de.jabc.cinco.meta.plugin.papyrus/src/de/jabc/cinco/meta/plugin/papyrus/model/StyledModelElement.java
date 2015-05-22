package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;

import style.LineStyle;
import style.Color;
import mgl.GraphicalModelElement;

public class StyledModelElement {
	private GraphicalModelElement modelElement;
	private LineStyle lineStyle;
	private Color foregroundColor, backgroundColor;
	private int lineWidth;
	private double transperancy;
	private ArrayList<String> label;
	private StyledLabel styledLabel;
	public GraphicalModelElement getModelElement() {
		return modelElement;
	}
	public void setModelElement(GraphicalModelElement modelElement) {
		this.modelElement = modelElement;
	}
	public LineStyle getLineStyle() {
		return lineStyle;
	}
	public void setLineStyle(LineStyle lineStyle) {
		this.lineStyle = lineStyle;
	}
	public Color getForegroundColor() {
		return foregroundColor;
	}
	public void setForegroundColor(Color foregroundColor) {
		this.foregroundColor = foregroundColor;
	}
	public Color getBackgroundColor() {
		return backgroundColor;
	}
	public void setBackgroundColor(Color backgroundColor) {
		this.backgroundColor = backgroundColor;
	}
	public int getLineWidth() {
		return lineWidth;
	}
	public void setLineWidth(int lineWidth) {
		this.lineWidth = lineWidth;
	}
	public double getTransperancy() {
		return transperancy;
	}
	public void setTransperancy(double transperancy) {
		this.transperancy = transperancy;
	}
	public ArrayList<String> getLabel() {
		return label;
	}
	public void setLabel(ArrayList<String> label) {
		this.label = label;
	}
	public StyledLabel getStyledLabel() {
		return styledLabel;
	}
	public void setStyledLabel(StyledLabel styledLabel) {
		this.styledLabel = styledLabel;
	}
	
	
	
	
}
