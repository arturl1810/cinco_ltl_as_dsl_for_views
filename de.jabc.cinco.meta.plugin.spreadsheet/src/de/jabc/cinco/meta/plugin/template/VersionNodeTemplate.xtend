package de.jabc.cinco.meta.plugin.template

class VersionNodeTemplate {
	def create(String packageName)'''
package «packageName»;

import graphmodel.Edge;
import graphmodel.Node;

import java.util.HashMap;
import java.util.Map;

public class VersionNode {
	public Node node;
	public Edge edge;
	public Map<String,String> formulars;
	public NodeStatus status;
	public VersionNode()
	{
		formulars = new HashMap<String,String>();
	}
	public String toString(){
		return node.toString() + " " + status.name();
	}
	public boolean equals(Object obj){
		if (this == obj) {
            return true;
        } else if (obj == null) {
            return false;
        } else if (obj instanceof VersionNode) {
            VersionNode vn = (VersionNode) obj;
            if (NodeUtil.getId(vn.node).equals(NodeUtil.getId(this.node)))
                return true;
        }
        return false;
	}
}



'''
}