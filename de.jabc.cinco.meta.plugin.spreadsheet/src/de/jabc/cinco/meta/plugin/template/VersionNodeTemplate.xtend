package de.jabc.cinco.meta.plugin.template

class VersionNodeTemplate {
	def create(String packageName)'''
package «packageName»;

import graphmodel.Node;

public class VersionNode {
	public Node node;
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
            if (NodeUtil.getNodeId(vn.node).equals(NodeUtil.getNodeId(this.node)))
                return true;
        }
        return false;
	}
}

'''
}