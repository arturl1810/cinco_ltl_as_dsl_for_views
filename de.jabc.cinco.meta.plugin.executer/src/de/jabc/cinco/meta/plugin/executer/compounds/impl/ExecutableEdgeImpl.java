package de.jabc.cinco.meta.plugin.executer.compounds.impl;

import java.util.LinkedList;
import java.util.List;

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableEdge;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableModelElement;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode;
import mgl.Edge;
import mgl.ModelElement;

public class ExecutableEdgeImpl implements ExecutableEdge{
	
	private List<ExecutableNode> sources;
	private List<ExecutableNode> targets;
	
	private mgl.Edge modelElement;
	private ExecutableEdge parent;
	
	public ExecutableEdgeImpl()
	{
		this.sources = new LinkedList<ExecutableNode>();
		this.targets = new LinkedList<ExecutableNode>();
	}
	
	public mgl.Edge getModelElement() {
		return (Edge) this.modelElement;
	};
	public ExecutableEdge getParent() {
		return (ExecutableEdge) this.parent;
	}
	public List<ExecutableNode> getSources() {
		return sources;
	}
	public void setSources(List<ExecutableNode> sources) {
		this.sources = sources;
	}
	public List<ExecutableNode> getTargets() {
		return targets;
	}
	public void setTargets(List<ExecutableNode> targets) {
		this.targets = targets;
	}

	@Override
	public void setModelElement(ModelElement modelElement) {
		this.modelElement = (Edge) modelElement;
		
	}

	@Override
	public void setParent(ExecutableModelElement parent) {
		this.parent = (ExecutableEdge) parent;
		
	}

	
	
}
