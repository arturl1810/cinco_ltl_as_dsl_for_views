package de.jabc.cinco.meta.plugin.executer.compounds;

import java.util.List;

public interface ExecutableGraphmodel extends ExecutableNodeContainer{
	
	public List<ExecutableModelElement> getModelElements();

	public void setModelElements(List<ExecutableModelElement> modelElements);
	
	public List<ExecutableContainer> getContainers();
	
	public List<ExecutableNode> getNodes();
	
	public List<ExecutableEdge> getEdges();
	
	public List<ExecutableNode> getExclusivelyNodes();

	public mgl.GraphModel getGraphModel();

	public void setGraphModel(mgl.GraphModel graphModel);
	
	public List<ExecutableNode> getContainableElements();
	
	public void setContainableElements(List<ExecutableNode> executableNodes);
	
	
}
