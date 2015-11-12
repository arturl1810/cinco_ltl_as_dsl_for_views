package de.jabc.cinco.meta.plugin.gratext.descriptor;

import org.eclipse.core.resources.IProject;

public class ProjectDescriptor extends Descriptor<IProject>{

	public ProjectDescriptor(IProject project) {
		super(project);
	}
	
	private String symbolicName;
	public String getSymbolicName() {
		return symbolicName;
	}
	public ProjectDescriptor setSymbolicName(String name) {
		this.symbolicName = name;
		return this;
	}
	
	private String targetName;
	public String getTargetName() {
		return targetName;
	}
	public ProjectDescriptor setTargetName(String name) {
		this.targetName = name;
		return this;
	}
	
}
