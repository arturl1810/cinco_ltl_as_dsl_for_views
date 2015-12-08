package de.jabc.cinco.meta.core.utils.dependency;

import java.util.HashSet;
import java.util.Set;

public class DependencyNode {
	private String path;
	private Set<String> dependsOf;

	public Set<String> getDependsOf() {
		return dependsOf;
	}

	public DependencyNode(String path){
		this.path = path;
		this.dependsOf = new HashSet<String>();
	}
	
	public boolean dependsOf(String path){
		return this.dependsOf.add(path);
	}
	
	public boolean removeDependency(String path){
		return this.dependsOf.remove(path);
	}
	

	public String getPath() {
		return this.path;
	}
	
}
