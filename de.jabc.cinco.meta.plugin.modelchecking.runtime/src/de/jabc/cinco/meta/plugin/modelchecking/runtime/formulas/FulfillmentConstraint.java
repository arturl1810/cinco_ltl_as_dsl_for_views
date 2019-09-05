package de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
import graphmodel.Node;

public enum FulfillmentConstraint {
	ALL_NODES,EACH_STARTNODE, ANY_STARTNODE;
	
	public <N,E> boolean fulfills(CheckableModel<N,E> checkModel, Set<Node> satisfyingNodes) {
		switch(this) {
			case ANY_STARTNODE: return satisfyingNodes.stream()
					.anyMatch(node -> isStartNode(checkModel, node));
			case EACH_STARTNODE:return satisfyingNodes.stream()
					.filter(node -> isStartNode(checkModel, node))
					.allMatch(node -> satisfyingNodes.contains(node));
			case ALL_NODES: {
				return checkModel.getNodes().size() == satisfyingNodes.size() &&
						satisfyingNodes.stream().map(node -> node.getId())
							.allMatch(id -> containsNode(checkModel, id));				
			}
					
		}
		return false;
	}
	
	private <N,E> boolean isStartNode(CheckableModel<N,E> checkModel, Node node) {
		N checkNode = getNodeById(checkModel, node.getId());
		if (checkNode != null) {
			return checkModel.isStartNode(checkNode);
		}
		return false;
	}
	
	private <N,E> boolean containsNode(CheckableModel<N,E> checkModel, String id) {
		return getNodeById(checkModel, id) != null;
	}
	
	private <N,E> N getNodeById(CheckableModel<N,E> checkModel, String id) {
		Set<N> nodes = checkModel.getNodes();
		N node = null;
		for (N n:nodes) {
			if (checkModel.getId(n).equals(id)) {
				node = n;
			}
		}
		return node;
	}
	
	public static FulfillmentConstraint defaultValue() {
		return ALL_NODES;
	}
}
