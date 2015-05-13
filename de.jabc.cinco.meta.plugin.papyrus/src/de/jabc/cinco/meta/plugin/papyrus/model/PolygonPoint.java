package de.jabc.cinco.meta.plugin.papyrus.model;

public class PolygonPoint {
	private int x,y;
	
	public PolygonPoint(int x,int y){
		this.x=x;
		this.y=y;
	}

	public int getX() {
		return x;
	}

	public void setX(int x) {
		this.x = x;
	}

	public int getY() {
		return y;
	}

	public void setY(int y) {
		this.y = y;
	}
	public String toString() {
		return x + " " + y;
	}
}
