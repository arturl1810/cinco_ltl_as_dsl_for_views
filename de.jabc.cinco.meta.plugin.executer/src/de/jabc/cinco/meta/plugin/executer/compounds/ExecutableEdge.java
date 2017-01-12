package de.jabc.cinco.meta.plugin.executer.compounds;

import java.util.List;

public interface ExecutableEdge extends ExecutableModelElement{
	
	
	public mgl.Edge getModelElement();
	public ExecutableEdge getParent();
	public List<ExecutableNode> getSources();
	public void setSources(List<ExecutableNode> sources);
	public List<ExecutableNode> getTargets();
	public void setTargets(List<ExecutableNode> targets);
	
	
}
