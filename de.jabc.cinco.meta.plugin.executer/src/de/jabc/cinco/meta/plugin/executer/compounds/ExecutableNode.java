package de.jabc.cinco.meta.plugin.executer.compounds;

import java.util.List;

public interface ExecutableNode extends ExecutableModelElement{
	
	
	public mgl.Node getModelElement();
	public void setModelElement(mgl.Node modelElement);
	public ExecutableNode getParent();
	public void setParent(ExecutableNode parent);
	public List<ExecutableEdge> getOutgoing();
	public void setOutgoing(List<ExecutableEdge> outgoing);
	public List<ExecutableEdge> getIncoming();
	public void setIncoming(List<ExecutableEdge> incoming);
	
	
}
