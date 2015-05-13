package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;

import style.Color;
import style.LineStyle;

public class StyledConnector {
	private int lineWidth;
	private LineStyle lineStyle;
	private Color foregroundColor, backgroundColor;
	private String polygonPoints;
	public int getLineWidth() {
		return lineWidth;
	}
	public void setLineWidth(int lineWidth) {
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
