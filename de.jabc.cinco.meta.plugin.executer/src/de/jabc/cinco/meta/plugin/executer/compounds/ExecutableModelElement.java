package de.jabc.cinco.meta.plugin.executer.compounds;

public interface ExecutableModelElement {

	public mgl.ModelElement getModelElement();
	public void setModelElement(mgl.ModelElement modelElement);
	public ExecutableModelElement getParent();
	public void setParent(ExecutableModelElement parent);
	
	
	
}
