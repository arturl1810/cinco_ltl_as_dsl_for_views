package de.jabc.cinco.meta.core.utils.dependency;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Stack;
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode;

public class DependencyGraph<T> {
	HashMap<T,DependencyNode<T>> nodes;
	
	public DependencyGraph(){
		this.nodes = new HashMap<T, DependencyNode<T>>();
	}
	
	public void addNode(DependencyNode<T> node){
		nodes.put(node.getPath(),node);
	}
	
	public  DependencyGraph<T> createGraph(Iterable<DependencyNode<T>> nodes){
		DependencyGraph<T> dpg = new DependencyGraph<T>();
		nodes.forEach(node -> dpg.addNode(node));
		
		return dpg;
	}
	
	
	public Stack<T> topSort(){
		Stack<T> stck = new Stack<>();
		List<T> toVisit = new ArrayList<>();
		
		for(T key: this.nodes.keySet()){
			if(nodes.get(key).getDependsOf().size()==0){
				stck.push(key);
			}else{
				toVisit.add(key);
			}
		}
	
		while(!toVisit.isEmpty()){
			List<T> toRemove = new ArrayList<T>();
			T lastCurrent =null;
 			for(T current: toVisit){
 				lastCurrent = current;
				DependencyNode<T> dn = nodes.get(current);
				for(T stacked : stck){
					dn.removeDependency(stacked);
					
				}
				if(dn.getDependsOf().size()==0){
					stck.push(current);
					toRemove.add(current);
				}
			}
 			if(!toRemove.isEmpty())
 				toVisit.removeAll(toRemove);
 			else
 				throw new RuntimeException(String.format("Could not resolve Dependencies, Dependency Graph contains circles, including '%s'.",lastCurrent));
		}
		return stck;
	}

	public void addNodes(List<DependencyNode<T>> nodes) {
	  nodes.forEach(n->this.addNode(n));
	}
}
