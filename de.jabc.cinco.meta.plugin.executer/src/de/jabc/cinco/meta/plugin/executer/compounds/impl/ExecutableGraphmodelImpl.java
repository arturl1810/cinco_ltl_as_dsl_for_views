package de.jabc.cinco.meta.plugin.executer.compounds.impl;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

import mgl.GraphModel;
import mgl.ModelElement;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableContainer;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableEdge;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableModelElement;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode;

public class ExecutableGraphmodelImpl implements ExecutableGraphmodel{
	private mgl.GraphModel graphModel;
	private List<ExecutableNode> containableNodes;
	
	
	private List<ExecutableModelElement> modelElements;
	
	public ExecutableGraphmodelImpl()
	{
		this.modelElements = new LinkedList<ExecutableModelElement>();
	}

	public List<ExecutableModelElement> getModelElements() {
		return modelElements;
	}

	public void setModelElements(List<ExecutableModelElement> modelElements) {
		this.modelElements = modelElements;
	}
	
	public List<ExecutableContainer> getContainers() {
		return this.modelElements.stream().filter(n->n instanceof ExecutableContainer).map(n->(ExecutableContainer)n).collect(Collectors.toList());
	}
	
	public List<ExecutableNode> getNodes() {
		return this.modelElements.stream().filter(n->n instanceof ExecutableNode).map(n->(ExecutableNode)n).collect(Collectors.toList());
	}
	
	public List<ExecutableNode> getExclusivelyNodes() {
		return this.modelElements.stream().filter(n->n instanceof ExecutableNode && !(n instanceof ExecutableContainer)).map(n->(ExecutableNode)n).collect(Collectors.toList());
	}

	public mgl.GraphModel getGraphModel() {
		return graphModel;
	}

	public void setGraphModel(mgl.GraphModel graphModel) {
		this.graphModel = graphModel;
	}

	public mgl.GraphModel getGraphmodel() {
		return this.graphModel;
	}
	
	public mgl.ModelElement getModelElement() {
		return this.graphModel;
	}

	@Override
	public ExecutableContainer getParent() {
		return null;
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
		this.graphModel = (GraphModel) modelElement;
		
	}

	@Override
	public void setParent(ExecutableModelElement parent) {
	}

	@Override
	public List<ExecutableNode> getContainableElements() {
		return this.containableNodes;
	}

	@Override
	public void setContainableElements(List<ExecutableNode> executableNodes) {
		this.containableNodes = executableNodes;
		
	}

	@Override
	public List<ExecutableEdge> getEdges() {
		return this.modelElements.stream().filter(n->n instanceof ExecutableEdge).map(n->(ExecutableEdge)n).collect(Collectors.toList());
	}
	
	
}
