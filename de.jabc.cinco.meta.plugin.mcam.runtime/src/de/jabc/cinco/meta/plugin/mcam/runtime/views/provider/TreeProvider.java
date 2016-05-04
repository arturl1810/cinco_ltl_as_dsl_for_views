package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;

public abstract class TreeProvider {

	private boolean resetted = true;

	public boolean isResetted() {
		return resetted;
	}

	public void reset() {
		resetted = true;
	}

	public void load(Object rootObject) {
		resetted = false;
		loadData(rootObject);
	}

	abstract protected void loadData(Object rootObject);

	abstract public TreeNode getTree();

	protected TreeNode findExistingNode(TreeNode node, TreeNode parentNode) {
		TreeNode existingNode = parentNode.find(node.getId());
		
		if (existingNode != null)
			return existingNode;

		parentNode.getChildren().add(node);
		node.setParent(parentNode);
		return node;
	}
}
