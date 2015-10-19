package de.jabc.cinco.meta.core.utils;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.util.EcoreUtil;

import mgl.Attribute;
import mgl.Edge;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;


public class InheritanceUtil {

	public static List<String> checkMGLInheritance(ModelElement me) {
		if (me instanceof Node) {
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
		Node curr = nodeContainer;
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
	
	public static List<Attribute> getInheritedAttributes(ModelElement me) {
		ArrayList<Attribute> attributes = new ArrayList<>();
		while (me != null) {
			attributes.addAll(me.getAttributes());
			if (me instanceof Node)
				me = ((Node) me).getExtends();
			if (me instanceof Edge)
				me = ((Edge) me).getExtends();
			if (me instanceof NodeContainer)
				me = ((NodeContainer) me).getExtends();
		}
		
		return attributes;
	}
}
