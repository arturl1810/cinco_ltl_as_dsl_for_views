package de.jabc.cinco.meta.plugin.executer.compounds.impl;

import java.util.LinkedList;
import java.util.List;

import mgl.ModelElement;
import mgl.Node;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableEdge;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableModelElement;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode;

public class ExecutableNodeImpl implements ExecutableNode{
	
	private List<ExecutableEdge> outgoing;
	private List<ExecutableEdge> incoming;
	
	private mgl.Node modelElement;
	private ExecutableNode parent;
	
	public ExecutableNodeImpl()
	{
		this.incoming = new LinkedList<ExecutableEdge>();
		this.outgoing = new LinkedList<ExecutableEdge>();
	}
	
	public mgl.Node getModelElement() {
		return this.modelElement;
	};
	public ExecutableNode getParent() {
			return parent;
	}
	public List<ExecutableEdge> getOutgoing() {
		return outgoing;
	}
	public void setOutgoing(List<ExecutableEdge> outgoing) {
		this.outgoing = outgoing;
	}
	public List<ExecutableEdge> getIncoming() {
		return incoming;
	}
	public void setIncoming(List<ExecutableEdge> incoming) {
		this.incoming = incoming;
	}

	@Override
	public void setModelElement(Node modelElement) {
		this.modelElement = modelElement;
		
	}

	@Override
	public void setParent(ExecutableModelElement parent) {
		this.parent = (ExecutableNode) parent;
		
	}

	@Override
	public void setModelElement(ModelElement modelElement) {
		this.modelElement = (Node) modelElement;
		
	}

	@Override
	public void setParent(ExecutableNode parent) {
		this.parent = parent;
		
	};
	
	
}
