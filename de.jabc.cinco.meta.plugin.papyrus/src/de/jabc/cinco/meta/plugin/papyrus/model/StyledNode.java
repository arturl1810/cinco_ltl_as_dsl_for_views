package de.jabc.cinco.meta.plugin.papyrus.model;

import java.util.ArrayList;

public class StyledNode extends StyledModelElement{
	private int angle, width, height;
	private NodeShape nodeShape;
	private int cornerWidth,cornerHeight;
	private ArrayList<PolygonPoint> polygonPoints;
	
	public int getAngle() {
		return angle;
	}
	public void setAngle(int angle) {
		this.angle = angle;
	}
	public int getWidth() {
		return width;
	}
	public void setWidth(int width) {
		this.width = width;
	}
	public int getHeight() {
		return height;
	}
	public void setHeight(int height) {
		this.height = height;
	}
	public int getCornerWidth() {
		return cornerWidth;
	}
	public void setCornerWidth(int cornerWidth) {
		this.cornerWidth = cornerWidth;
	}
	public int getCornerHeight() {
		return cornerHeight;
	}
	public void setCornerHeight(int cornerHeight) {
		this.cornerHeight = cornerHeight;
	}
	public NodeShape getNodeShape() {
		return nodeShape;
	}
	public void setNodeShape(NodeShape nodeShape) {
		this.nodeShape = nodeShape;
	}
	public ArrayList<PolygonPoint> getPolygonPoints() {
		return polygonPoints;
	}
	public void setPolygonPoints(ArrayList<PolygonPoint> polygonPoints) {
		this.polygonPoints = polygonPoints;
	}
	
	
}
