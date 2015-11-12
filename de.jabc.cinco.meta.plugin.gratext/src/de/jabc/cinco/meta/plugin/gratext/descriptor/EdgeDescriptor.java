package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.HashSet;
import java.util.Set;

import mgl.Edge;
import mgl.ModelElement;
import mgl.Node;

public class EdgeDescriptor extends ModelElementDescriptor<Edge> {
	
	private Set<Node> sourceNodes;
	private Set<Node> targetNodes;
	
	public EdgeDescriptor(Edge edge, GraphModelDescriptor model) {
		super(edge, model);
	}
	
	@Override
	protected void init() {
		super.init();
		sourceNodes = new HashSet<>();
		targetNodes = new HashSet<>();
	}
	
	@Override
	protected void initAttributes(ModelElement element) {
		super.initAttributes(element);
		if (((Edge)element).getExtends() != null) {
			initAttributes(((Edge)element).getExtends());
		}
	}
	
	public void addSourceNode(Node node) {
		//System.out.println(instance().getName() + ".sourceNode = " + node.getName());
		sourceNodes.add(node);
	}
	
	public void addTargetNode(Node node) {
		//System.out.println(instance().getName() + ".targetNode = " + node.getName());
		targetNodes.add(node);
	}
	
	public boolean sourceExists() {
		return !sourceNodes.isEmpty();
	}
	
	public boolean targetExists() {
		return !targetNodes.isEmpty();
	}
	
	public Set<Node> getSourceNodes() {
		return sourceNodes;
	}
	
	public Set<Node> getTargetNodes() {
		return targetNodes;
	}
	
	public Edge getSuperType() {
		return instance().getExtends();
	}
}
