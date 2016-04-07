package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import java.util.ArrayList;
import java.util.List;

public abstract class TreeNode {

	protected String label = null;
	protected Object data = null;
	private TreeNode parent = null;
	private List<TreeNode> children = new ArrayList<TreeNode>();

	TreeNode(Object data) {
		super();
		this.data = data;
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

	public void setChildren(List<TreeNode> children) {
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

	abstract public String getId();

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

	@Override
	public String toString() {
		String output = "TreeNode of: " + data + "\n";
		for (TreeNode treeNode : children) {
			output += " - " + treeNode.toString();
		}
		return output;
	}
}
