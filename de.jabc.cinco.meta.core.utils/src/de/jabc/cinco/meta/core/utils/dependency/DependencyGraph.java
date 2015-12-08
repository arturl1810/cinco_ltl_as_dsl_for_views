package de.jabc.cinco.meta.core.utils.dependency;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.Stack;

public class DependencyGraph {
	HashMap<String,DependencyNode> nodes;
	private List<String> ignore;
	
	public DependencyGraph(List<String> ignore){
		this.ignore = ignore;
		this.nodes = new HashMap<String, DependencyNode>();
	}
	
	public void addNode(DependencyNode node){
		nodes.put(node.getPath(),node);
	}
	
	public static DependencyGraph createGraph(Collection<DependencyNode> nodes, List<String> stacked){
		DependencyGraph dpg = new DependencyGraph(stacked);
		nodes.forEach(node -> dpg.addNode(node));
		
		return dpg;
	}
	
	
	public Stack<String> topSort(){
		Stack<String> stck = new Stack<>();
		List<String> toVisit = new ArrayList<>();
		
		for(String key: this.nodes.keySet()){
			if(nodes.get(key).getDependsOf().size()==0){
				stck.push(key);
			}else{
				toVisit.add(key);
			}
		}
	
		while(!toVisit.isEmpty()){
			List<String> toRemove = new ArrayList<String>();
 			for(String current: toVisit){
				DependencyNode dn = nodes.get(current);
				for(String ign: this.ignore){
					dn.removeDependency(ign);
				}
				for(String stacked : stck){
					dn.removeDependency(stacked);
					
				}
				if(dn.getDependsOf().size()==0){
					stck.push(current);
					toRemove.add(current);
				}
			}
 			toVisit.removeAll(toRemove);
		}
		
		
		
		
		return stck;
	}
}
