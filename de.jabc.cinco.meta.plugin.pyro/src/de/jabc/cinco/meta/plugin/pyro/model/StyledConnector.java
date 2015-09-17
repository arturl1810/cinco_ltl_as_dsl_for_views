package de.jabc.cinco.meta.plugin.pyro.model;


import style.Color;
import style.LineStyle;

public class StyledConnector {
	private double lineWidth;
	private LineStyle lineStyle;
	private Color foregroundColor, backgroundColor;
	private String polygonPoints;
	public double getLineWidth() {
		return lineWidth;
	}
	public void setLineWidth(double lineWidth) {
		this.lineWidth = lineWidth;
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
	public LineStyle getLineStyle() {
		return lineStyle;
	}
	public void setLineStyle(LineStyle lineStyle) {
		this.lineStyle = lineStyle;
	}
	public String getPolygonPoints() {
		return polygonPoints;
	}
	public void setPolygonPoints(String polygonPoints) {
		this.polygonPoints = polygonPoints;
	}
	
	
	
	
}
