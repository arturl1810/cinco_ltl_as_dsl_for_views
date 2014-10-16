package de.jabc.cinco.meta.core.utils;

import java.util.ArrayList;
import java.util.List;

import mgl.Edge;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;


public class InheritanceUtil {

	public static List<String> checkMGLInheritance(ModelElement me) {
		if (me instanceof Node) {
			System.out.println("Checking node inheritence structure");
			return checkNodeInheritance((Node) me);
		}
		if (me instanceof Edge) {
			return checkEdgeInheritance((Edge) me);
		}
		if (me instanceof NodeContainer) {
			return checkNodeContainerInheritance((NodeContainer) me);
		}
		return null;
	}
	
	private static List<String> checkNodeInheritance(Node node) {
		Node curr = node;
		List<String> ancestors = new ArrayList<>();
		while (curr != null) {
			if (ancestors.contains(curr.getName())) {
				return ancestors;
			}
			ancestors.add(curr.getName());
			curr = curr.getExtends();
		}
		
		return null;
	}
	
	private static List<String> checkEdgeInheritance(Edge edge) {
		Edge curr = edge;
		List<String> ancestors = new ArrayList<>();
		while (curr != null) {
			if (ancestors.contains(curr.getName())) {
				return ancestors;
			}
			ancestors.add(curr.getName());
			curr = curr.getExtends();
		}
		
		return null;
	}
	
	private static List<String> checkNodeContainerInheritance(NodeContainer nodeContainer) {
		NodeContainer curr = nodeContainer;
		List<String> ancestors = new ArrayList<>();
		while (curr != null) {
			if (ancestors.contains(curr.getName())) {
				return ancestors;
			}
			ancestors.add(curr.getName());
			curr = curr.getExtends();
		}
		
		return null;
	}
}
