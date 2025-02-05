package de.jabc.cinco.meta.plugin.template

import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode
import java.util.ArrayList

class VersionNodeTemplate {
	def create(String packageName, ArrayList<ResultNode> nodes)'''
package «packageName»;

import graphmodel.Edge;
import graphmodel.Node;

import java.util.HashMap;
import java.util.Map;

public class VersionNode {
	public Node node;
	public Edge edge;
	public Map<String,String> formulas;
	public NodeStatus status;
	public VersionNode()
	{
		formulas = new HashMap<String,String>();
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
	
	public String getAdditionalSheetPath()
	{
		«FOR n : nodes»
		«IF n.additionalSheet != null»
		if(node.eClass().getName().equals("«n.nodeName»")) {
			return "«n.additionalSheet»";
		}
		«ENDIF»
		«ENDFOR»
		return null;
	}
}



'''
}