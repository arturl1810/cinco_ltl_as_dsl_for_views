package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;

import style.Color;

public class StyledConnector {
	private int lineWidth;
	private Color foregroundColor, backgroundColor;
	private ArrayList<PolygonPoint> polygonPoints;
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
	public ArrayList<PolygonPoint> getPolygonPoints() {
		return polygonPoints;
	}
	public void setPolygonPoints(ArrayList<PolygonPoint> polygonPoints) {
		this.polygonPoints = polygonPoints;
	}
	
	
	
	
}
