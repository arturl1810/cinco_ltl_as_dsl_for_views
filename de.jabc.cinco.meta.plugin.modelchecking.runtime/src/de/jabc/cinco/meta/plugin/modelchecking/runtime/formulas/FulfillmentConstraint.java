package de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas;

import java.util.Set;
import java.util.stream.Collectors;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
import graphmodel.Node;

public enum FulfillmentConstraint {
	ALL_NODES,EACH_STARTNODE, ANY_STARTNODE;
	
	public <N,E> boolean fulfills(CheckableModel<N,E> checkableModel, Set<Node> satisfyingNodes) {
		switch(this) {
			case ANY_STARTNODE: return satisfyingNodes.stream()
					.anyMatch(node -> isStartNode(checkableModel, node));
			case EACH_STARTNODE:return satisfyingNodes.stream()
					.map(node -> node.getId())
					.collect(Collectors.toSet())
					.containsAll(
						checkableModel.getNodes().stream().filter(node -> checkableModel.isStartNode(node))
							.map(node -> checkableModel.getId(node)).collect(Collectors.toSet())							
					);
			case ALL_NODES: {
				return checkableModel.getNodes().size() == satisfyingNodes.size() &&
						satisfyingNodes.stream().map(node -> node.getId())
							.allMatch(id -> containsNode(checkableModel, id));				
			}
					
		}
		return false;
	}
	
	private <N,E> boolean isStartNode(CheckableModel<N,E> checkableModel, Node node) {
		N checkableNode = getNodeById(checkableModel, node.getId());
		if (checkableNode != null) {
			return checkableModel.isStartNode(checkableNode);
		}
		return false;
	}
	
	private <N,E> boolean containsNode(CheckableModel<N,E> checkableModel, String id) {
		return getNodeById(checkableModel, id) != null;
	}
	
	private <N,E> N getNodeById(CheckableModel<N,E> checkableModel, String id) {
		Set<N> nodes = checkableModel.getNodes();
		N node = null;
		for (N n:nodes) {
			if (checkableModel.getId(n).equals(id)) {
				node = n;
			}
		}
		return node;
	}
	
	public static FulfillmentConstraint defaultValue() {
		return ALL_NODES;
	}
}
