package de.jabc.cinco.meta.plugin.pyro.model;


import java.util.ArrayList;

import mgl.GraphicalModelElement;
import mgl.NodeContainer;

public class EmbeddingConstraint {
	private ArrayList<GraphicalModelElement> validNode;
	private NodeContainer container;
	private int lowBound, highBound;
	
	
	public ArrayList<GraphicalModelElement> getValidNode() {
		return validNode;
	}
	public void setValidNode(ArrayList<GraphicalModelElement> validNode) {
		this.validNode = validNode;
	}
	public int getLowBound() {
		return lowBound;
	}
	public void setLowBound(int lowBound) {
		this.lowBound = lowBound;
	}
	public int getHighBound() {
		return highBound;
	}
	public void setHighBound(int highBound) {
		this.highBound = highBound;
	}
	public NodeContainer getContainer() {
		return container;
	}
	public void setContainer(NodeContainer container) {
		this.container = container;
	}
	
	
}
