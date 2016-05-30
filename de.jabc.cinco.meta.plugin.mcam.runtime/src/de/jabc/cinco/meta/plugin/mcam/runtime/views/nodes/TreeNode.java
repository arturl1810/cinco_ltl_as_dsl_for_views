package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public abstract class TreeNode {
	
	protected UUID uuid = null;

	protected String label = null;
	protected Object data = null;
	private TreeNode parent = null;
	private ArrayList<TreeNode> children = new ArrayList<TreeNode>();

	public TreeNode(Object data) {
		super();
		this.data = data;
		this.uuid = UUID.randomUUID();
	}

	public Object getData() {
		return data;
	}

	public void setData(Object data) {
		this.data = data;
	}

	public TreeNode getParent() {
		return parent;
	}

	public void setParent(TreeNode parent) {
		this.parent = parent;
	}

	public List<TreeNode> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<TreeNode> children) {
		this.children = children;
	}

	public String getLabel() {
		if (label != null)
			return label;
		return this.toString();
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public abstract String getId();

	public String getPathIdentifier() {
		String ident = getId();
		if (parent != null)
			ident = parent.getPathIdentifier() + "/" + ident;
		return ident;
	}

	public TreeNode find(String id) {
		if (getId() == null || id == null)
			return null;
		if (id.equals(getId()))
			return this;
		for (TreeNode child : children) {
			TreeNode result = child.find(id);
			if (result != null)
				return result;
		}
		return null;
	}
	
	public int hashCode() {
		String pathId = getPathIdentifier();
		final int prime = 19;
		int result = 1;
		result = prime * result + ((pathId == null) ? 0 : pathId.hashCode());
		return result;
	}
	
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (obj instanceof TreeNode == false)
			return false;
		
		TreeNode node = (TreeNode) obj;
		return this.getPathIdentifier().equals(node.getPathIdentifier());
	}

	@Override
	public String toString() {
		String output = "TreeNode of: " + data.getClass().getSimpleName() + "\n";
		for (TreeNode treeNode : children) {
			output += " - " + treeNode.toString();
		}
		return output;
	}
}
