package de.jabc.cinco.meta.core.utils.dependency;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode;

public class DependencyNode<T> {
	private T path;
	private Set<T> dependsOf;

	public Set<T> getDependsOf() {
		return dependsOf;
	}

	public DependencyNode(T path){
		this.path = path;
		this.dependsOf = new HashSet<T>();
	}
	
	public boolean dependsOf(T path){
		return this.dependsOf.add(path);
	}
	
	public boolean removeDependency(T path){
		return this.dependsOf.remove(path);
	}
	

	public T getPath() {
		return this.path;
	}

	public boolean addDependencies(Collection<T> strings) {
	  return dependsOf.addAll(strings);
	}
	
	@Override
	public String toString() {
		return "DependencyNode [path=" + path + "]";
	}
	
}
