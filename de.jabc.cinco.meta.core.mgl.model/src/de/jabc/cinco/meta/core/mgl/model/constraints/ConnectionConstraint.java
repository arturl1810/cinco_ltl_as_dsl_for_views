package de.jabc.cinco.meta.core.mgl.model.constraints;

import graphmodel.Edge;
import graphmodel.Node;

import java.util.Arrays;
import java.util.List;

public class ConnectionConstraint {
	private int upperBound;
	public int getUpperBound() {
		return upperBound;
	}

	public void setUpperBound(int upperBound) {
		this.upperBound = upperBound;
	}

	public int getLowerBound() {
		return lowerBound;
	}

	public void setLowerBound(int lowerBound) {
		this.lowerBound = lowerBound;
	}

	private int lowerBound;
	private boolean outgoing;
	private List<Class<? extends Edge>> edgeClasses;

	@SafeVarargs
	public ConnectionConstraint( boolean outgoing,int lowerBound,int upperBound, Class<? extends Edge> ...edgeClasses){
		this.edgeClasses = Arrays.asList(edgeClasses); 
		this.lowerBound = lowerBound;
		this.upperBound = upperBound!=-1?upperBound:Integer.MAX_VALUE;
		this.outgoing = outgoing;
	}
	
	public boolean violationAfterConnect(Node from, Edge with, Node to){
		if(this.outgoing)
			return !canConnect(from,with.getClass());
		else
			return !canConnect(to,with.getClass());
		
	}
	
	
	public boolean isInEdges(Class<? extends Edge> edgeType){
		return edgeClasses.stream().anyMatch(c -> c.isAssignableFrom(edgeType));
		
	}

	public boolean canConnect(Node node, Class<? extends Edge> edgeType) {
		int count = 0;
		
		if(isInEdges(edgeType)){
			if(this.outgoing)
				count = node.getOutgoing(edgeType).size();
			else
				count = node.getIncoming(edgeType).size();
		
			return count < upperBound;
		}
		return false;
	}
}
