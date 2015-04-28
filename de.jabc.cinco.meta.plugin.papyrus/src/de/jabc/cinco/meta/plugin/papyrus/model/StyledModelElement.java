package de.jabc.cinco.meta.plugin.papyrus.model;

import style.LineStyle;
import style.Color;
import mgl.GraphicalModelElement;

public class StyledModelElement {
	private GraphicalModelElement modelElement;
	private LineStyle lineStyle;
	private Color foregroundColor, backgroundColor, labelColor;
	private int lineWidth;
	private double transperancy;
	private Object label;
	private int labelFontSize;
	private LableAlignment lableAlignment;
	private String fontName;
	private FontType fontType;
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
	public Color getLabelColor() {
		return labelColor;
	}
	public void setLabelColor(Color labelColor) {
		this.labelColor = labelColor;
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
	public Object getLabel() {
		return label;
	}
	public void setLabel(Object label) {
		this.label = label;
	}
	public int getLabelFontSize() {
		return labelFontSize;
	}
	public void setLabelFontSize(int labelFontSize) {
		this.labelFontSize = labelFontSize;
	}
	public String getFontName() {
		return fontName;
	}
	public void setFontName(String fontName) {
		this.fontName = fontName;
	}
	public LableAlignment getLableAlignment() {
		return lableAlignment;
	}
	public void setLableAlignment(LableAlignment lableAlignment) {
		this.lableAlignment = lableAlignment;
	}
	public FontType getFontType() {
		return fontType;
	}
	public void setFontType(FontType fontType) {
		this.fontType = fontType;
	}
	
	
	
}
