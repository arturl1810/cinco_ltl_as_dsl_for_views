package de.jabc.cinco.meta.core.utils.dependency;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Stack;

public class DependencyGraph {
	HashMap<String,DependencyNode> nodes;
	
	public DependencyGraph(){
		this.nodes = new HashMap<String, DependencyNode>();
	}
	
	public void addNode(DependencyNode node){
		nodes.put(node.getPath(),node);
	}
	
	public static DependencyGraph createGraph(Collection<DependencyNode> nodes){
		DependencyGraph dpg = new DependencyGraph();
		nodes.forEach(node -> dpg.addNode(node));
		return dpg;
	}
	
	
	public Stack<String> topSort(){
		Stack<String> stck = new Stack<>();
		List<String> toVisit = new ArrayList<>();
		
		// Init: get root elements
		for(String key: this.nodes.keySet()){
			if(nodes.get(key).getDependsOf().size()==0){
				stck.push(key);
			}else{
				toVisit.add(key);
			}
		}
	
		while(!toVisit.isEmpty()){
			List<String> toRemove = new ArrayList<String>();
			String lastCurrent ="";
 			for(String current: toVisit){
 				lastCurrent = current;
				DependencyNode dn = nodes.get(current);
				for(String stacked : stck){
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
 				throw new RuntimeException(String.format("Could not resolve MGL Dependencies, Dependency Graph contains circles, including '%s'.",lastCurrent));
		}
		return stck;
	}
}
