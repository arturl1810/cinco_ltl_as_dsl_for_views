package de.jabc.cinco.meta.plugin.executer.collector;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import mgl.Node;
import mgl.NodeContainer;
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
		//Nodes
		eg.getModelElements().addAll(graphModel.getNodes().stream().map(n->convertNode(n)).collect(Collectors.toList()));
		
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
		ExecutableNode en = null;
		if(node instanceof NodeContainer){
			if(container.containsKey(node.getName())){
				return container.get(node.getName());
			}
			en = new ExecutableContainerImpl();
			container.put(node.getName(), (ExecutableContainer) en);
			mgl.NodeContainer nodeContainer = (NodeContainer) node;
			ExecutableContainer ec = (ExecutableContainer) en;
			ec.getContainableNodes().
				addAll(
					(Collection<? extends ExecutableNode>) nodeContainer.
					getContainableElements().
					stream().
					flatMap(
							n->n.
							getTypes().
							stream().
							map(
								e->convertNode((Node) e)
								)
							).
					collect(Collectors.toList())
				);

		}else{
			if(nodes.containsKey(node.getName())){
				return nodes.get(node.getName());
			}
			
			en = new ExecutableNodeImpl();
		}
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
		if(en.getParent()!=null){
			en.getIncoming().addAll(en.getParent().getIncoming());			
			en.getOutgoing().addAll(en.getParent().getOutgoing());			
		}

		en.getIncoming().addAll(
				(Collection<? extends ExecutableEdge>) node.
				getIncomingEdgeConnections().
				stream().
				flatMap(
						n->n.getConnectingEdges().stream().map(e->convertEdge(e))
						).
				collect(Collectors.toSet())
				);
		en.getOutgoing().addAll(
				(Collection<? extends ExecutableEdge>) node.
				getOutgoingEdgeConnections().
				stream().
				flatMap(
						n->n.getConnectingEdges().stream().map(e->convertEdge(e))
						).
				collect(Collectors.toSet())
				);
		
		
		return en;
		
	}


	public Map<String, ExecutableEdge> getEdges() {
		return edges;
	}


	public void setEdges(Map<String, ExecutableEdge> edges) {
		this.edges = edges;
	}


	public Map<String, ExecutableNode> getNodes() {
		return nodes;
	}


	public void setNodes(Map<String, ExecutableNode> nodes) {
		this.nodes = nodes;
	}


	public Map<String, ExecutableContainer> getContainer() {
		return container;
	}


	public void setContainer(Map<String, ExecutableContainer> container) {
		this.container = container;
	}


	public Map<String, Set<ExecutableNode>> getSources() {
		return sources;
	}


	public void setSources(Map<String, Set<ExecutableNode>> sources) {
		this.sources = sources;
	}


	public Map<String, Set<ExecutableNode>> getTargets() {
		return targets;
	}


	public void setTargets(Map<String, Set<ExecutableNode>> targets) {
		this.targets = targets;
	}

	
}


