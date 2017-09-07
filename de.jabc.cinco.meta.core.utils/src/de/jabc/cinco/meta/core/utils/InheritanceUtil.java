package de.jabc.cinco.meta.core.utils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.google.common.collect.Lists;

import mgl.Attribute;
import mgl.Edge;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.UserDefinedType;


public class InheritanceUtil {

	public List<String> checkMGLInheritance(ModelElement me) {
		if (me instanceof Node) {
			return checkNodeInheritance((Node) me);
		}
		if (me instanceof Edge) {
			return checkEdgeInheritance((Edge) me);
		}
		
		if (me instanceof UserDefinedType){
			return checkUserDefinedTypeInheritance((UserDefinedType)me);
		}
		return null;
	}
	
	private  List<String> checkUserDefinedTypeInheritance(
			UserDefinedType type) {
		UserDefinedType curr = type;
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

	private List<String> checkNodeInheritance(Node node) {
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
	
public List<Attribute> getInheritedAttributes(ModelElement me) {
		ArrayList<Attribute> attributes = new ArrayList<>();
		List<String> checked = checkMGLInheritance(me);
		while (me != null && (checked==null || checked.isEmpty()) ) {
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
	
	public Node getLowestMutualSuperNode(Iterable<Node> nodes){
		if(nodes!=null){
		HashSet<Node> superNodes = new HashSet<Node>();
		boolean first = true;
		for(Node node: nodes){
			if(first){
				superNodes.addAll(getAllSuperNodes(node));
				first = false;
			}else{
				superNodes.retainAll(getAllSuperNodes(node));
			}
			
		}
		if(superNodes.size()==1){
			return superNodes.toArray(new Node[1])[0];
		}else if(superNodes.size()>1){
			return sortByInheritance(Lists.newArrayList(superNodes)).get(superNodes.size()-1);
		}else{
			return null;
		}
		}
		return null;
	}
	
	private List<Node> sortByInheritance(List<Node> nodes) {
		
		nodes.sort(new Comparator<Node>() {

			@Override
			public int compare(Node o1, Node o2) {
				int j=0,i = 0;
				Node sn = o1.getExtends();
				while(sn != null){
					sn = sn.getExtends();
					i++;
				}
				sn = o2.getExtends();
				while(sn != null){
					sn = sn.getExtends();
					j++;
				}
				return Integer.compare(i, j);
			}

			
		});
		return nodes;
		
		
	}

	
	
	public Set<Node> getAllSuperNodes(Node node){
		HashSet<Node> superNodes = new HashSet<Node>();
		superNodes.add(node);
		Node superNode = node.getExtends();
		List<String> checked = checkMGLInheritance(superNode);
		while(superNode!=null && (checked == null || checked.isEmpty())){
			superNodes.add(superNode);
			superNode = superNode.getExtends();
		}
		return superNodes;
		
	}
}
