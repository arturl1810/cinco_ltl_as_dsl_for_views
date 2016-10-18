package de.jabc.cinco.meta.plugin.executer.collector;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableContainer;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableEdge;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel;
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode;
import de.jabc.cinco.meta.plugin.executer.compounds.impl.ExecutableContainerImpl;
import de.jabc.cinco.meta.plugin.executer.compounds.impl.ExecutableEdgeImpl;
import de.jabc.cinco.meta.plugin.executer.compounds.impl.ExecutableGraphmodelImpl;
import de.jabc.cinco.meta.plugin.executer.compounds.impl.ExecutableNodeImpl;

public class GraphmodelCollector {
	
	private Map<String,ExecutableEdge> edges;
	private Map<String,ExecutableNode> nodes;
	private Map<String,ExecutableContainer> container;
	
	private Map<String,Set<ExecutableNode>> sources;
	private Map<String,Set<ExecutableNode>> targets;
	
	public GraphmodelCollector()
	{
		this.edges = new HashMap<String, ExecutableEdge>();
		this.nodes = new HashMap<String,ExecutableNode>();
		this.container = new HashMap<String, ExecutableContainer>();
		
		this.sources = new HashMap<String, Set<ExecutableNode>>();
		this.targets = new HashMap<String, Set<ExecutableNode>>();
	}
	
	
	public ExecutableGraphmodel transfrom(mgl.GraphModel graphModel)
	{
		ExecutableGraphmodel eg = new ExecutableGraphmodelImpl();
		
		eg.setGraphModel(graphModel);
		
		//Edges
		eg.getModelElements().addAll(graphModel.getEdges().stream().map(n->convertEdge(n)).collect(Collectors.toList()));
		
		return eg;
	}
	
	public ExecutableEdge convertEdge(mgl.Edge edge)
	{
		if(edges.containsKey(edge.getName())){
			return edges.get(edge.getName());
		}
		ExecutableEdge ee = new ExecutableEdgeImpl();
		edges.put(edge.getName(), ee);
		ee.setModelElement(edge);
		
		if(edge.getExtends()!=null){
			String key = edge.getExtends().getName();
			if(edges.containsKey(key))
			{
				ee.setParent(edges.get(key));
			}
			else{
				ee.setParent(convertEdge(edge.getExtends()));
			}
		}
		
		//TODO sources + targets
		
		return ee;
		
	}
	
	public ExecutableNode convertNode(mgl.Node node)
	{
		if(nodes.containsKey(node.getName())){
			return nodes.get(node.getName());
		}
		ExecutableNode en = new ExecutableNodeImpl();
		nodes.put(node.getName(), en);
		en.setModelElement(node);
		
		if(node.getExtends()!=null){
			String key = node.getExtends().getName();
			if(nodes.containsKey(key))
			{
				en.setParent(nodes.get(key));
			}
			else{
				en.setParent(convertNode(node.getExtends()));
			}
		}
		
		en.getIncoming().addAll(en.getParent().getIncoming());
//		en.getIncoming().addAll(
//				node.
//				getIncomingEdgeConnections().
//				stream().
//				map((n)->{
//					//this.targets.put(key, value)
//					return convertEdge(n.getConnectingEdges());
//					}).
//				collect(Collectors.toList())
//				);
		
		
		return en;
		
	}

	
}


