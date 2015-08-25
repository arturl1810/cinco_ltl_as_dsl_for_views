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
		if(isInEdges(with)){
			int count = 0;
			if(this.outgoing){
				count = from.getOutgoing(with.getClass()).size();
			}else{
				count = to.getIncoming(with.getClass()).size();
			}
			
			return count+1>upperBound;
			
		}
		
		return false;
		
	}
	
	public boolean isInEdges(Edge edge){
		for(Class<? extends Edge> clazz: edgeClasses){
			if(clazz.isInstance(edge))
				return true;
		}
		return false;
	}
}
