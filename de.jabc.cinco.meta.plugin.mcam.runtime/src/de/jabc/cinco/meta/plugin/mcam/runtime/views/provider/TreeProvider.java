package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;

public abstract class TreeProvider {

	private boolean updateNeeded = true;

	public boolean isUpdateNeeded() {
		return updateNeeded;
	}

	public void flagDirty() {
		updateNeeded = true;
	}

	public void flagClean() {
		updateNeeded = true;
	}

	public void load(Object rootObject) {
		synchronized (this) {
			if (updateNeeded) {
				loadData(rootObject);
				updateNeeded = false;
			}
		}
	}

	abstract protected void loadData(Object rootObject);

	public TreeNode getTree() {
		synchronized (this) {
			return getTreeRoot();
		}
	}

	abstract protected TreeNode getTreeRoot();

	protected TreeNode findExistingNode(TreeNode node, TreeNode parentNode) {
		TreeNode existingNode = parentNode.find(node.getId());

		if (existingNode != null)
			return existingNode;

		parentNode.getChildren().add(node);
		node.setParent(parentNode);
		return node;
	}
}
