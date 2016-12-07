package de.jabc.cinco.meta.plugin.executer.compounds;

import java.util.List;

public interface ExecutableNodeContainer extends ExecutableModelElement{
	
	
	public mgl.ModelElement getModelElement();
	public List<ExecutableNode> getContainableNodes();
	public void setContainableNodes(List<ExecutableNode> containableNodes);
}
