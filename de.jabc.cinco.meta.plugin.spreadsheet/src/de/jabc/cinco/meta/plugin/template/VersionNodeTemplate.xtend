package de.jabc.cinco.meta.plugin.template

class VersionNodeTemplate {
	def create(String packageName)'''
package «packageName»;

import graphmodel.Edge;
import graphmodel.Node;

public class VersionNode {
	public Node node;
	public Edge edge;
	public NodeStatus status;
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