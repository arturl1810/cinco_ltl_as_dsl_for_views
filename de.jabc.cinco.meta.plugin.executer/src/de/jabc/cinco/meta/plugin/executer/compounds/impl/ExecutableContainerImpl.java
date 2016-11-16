package de.jabc.cinco.meta.plugin.executer.compounds.impl;

import java.util.LinkedList;
import java.util.List;

import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableContainer;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableEdge;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableModelElement;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode;

public class ExecutableContainerImpl implements ExecutableContainer {

	private List<ExecutableEdge> outgoing;
	private List<ExecutableEdge> incoming;
	
	private mgl.NodeContainer modelElement;
	private ExecutableContainer parent;
	
	private List<ExecutableNode> containableNodes;
	
	public ExecutableContainerImpl() {
		this.outgoing = new LinkedList<ExecutableEdge>();
		this.incoming = new LinkedList<ExecutableEdge>();
		this.containableNodes = new LinkedList<ExecutableNode>();
	}
	
	@Override
	public List<ExecutableNode> getContainableNodes() {
		return this.containableNodes;
	}

	@Override
	public void setContainableNodes(List<ExecutableNode> containableNodes) {
		this.containableNodes = containableNodes;

	}

	@Override
	public void setModelElement(ModelElement modelElement) {
		this.modelElement = (NodeContainer) modelElement;

	}

	@Override
	public void setParent(ExecutableModelElement parent) {
		this.parent = (ExecutableContainer) parent;

	}

	@Override
	public Node getModelElement() {
		return this.modelElement;
	}

	@Override
	public void setModelElement(Node modelElement) {
		this.modelElement = (NodeContainer) modelElement;

	}

	@Override
	public ExecutableNode getParent() {
		return parent;
	}

	@Override
	public void setParent(ExecutableNode parent) {
		this.parent = (ExecutableContainer) parent;

	}

	@Override
	public List<ExecutableEdge> getOutgoing() {
		return this.outgoing;
	}

	@Override
	public void setOutgoing(List<ExecutableEdge> outgoing) {
		this.outgoing = outgoing;

	}

	@Override
	public List<ExecutableEdge> getIncoming() {
		return incoming;
	}

	@Override
	public void setIncoming(List<ExecutableEdge> incoming) {
		this.incoming = incoming;

	}

}
