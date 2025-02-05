package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import graphmodel.GraphModel;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeProcess;

import java.util.Set;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.ContainerTreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.IdNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;

public class ConflictViewTreeProvider<E extends _CincoId, M extends GraphModel, A extends _CincoAdapter<E, M>>
		extends TreeProvider {

	private ConflictViewPage<E, M, A> page;

	public enum ViewType {
		BY_ID
	}

	private ContainerTreeNode byIdRoot;

	private ViewType activeView = ViewType.BY_ID;

	private MergeProcess<E, A> mp;

	public ConflictViewTreeProvider(ConflictViewPage<E, M, A> page) {
		super();
		this.page = page;
	}

	@Override
	public TreeNode getTreeRoot() {
		switch (activeView) {
		case BY_ID:
		default:
			return byIdRoot;
		}
	}

	public ViewType getActiveView() {
		return activeView;
	}

	public void setActiveView(ViewType activeView) {
		this.activeView = activeView;
	}

	public MergeProcess<E, A> getMergeProcess() {
		return mp;
	}

	@Override
	public void loadData(Object rootObject) {
		final long timeStart = System.currentTimeMillis();

		mp = page.getMp();
		final long timeLoad = System.currentTimeMillis();

		buildTree();
		final long timeBuild = System.currentTimeMillis();

		System.out.println(page.getClass().getSimpleName()
				+ " - load: " + (timeLoad - timeStart)
				+ " ms / build: " + (timeBuild - timeLoad) + " ms");
	}

	protected void buildTree() {
		byIdRoot = new ContainerTreeNode(null, "byIdRoot");
		for (MergeInformation<E, A> mergeInfo : mp.getMergeInformationMap()
				.values()) {
			if (mergeInfo.getLocalChanges().size() > 0
					|| mergeInfo.getRemoteChanges().size() > 0)
				buildTreeById(mergeInfo.getId(), byIdRoot);
		}
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeById(Object obj, TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(null, "dummy");

		if (obj instanceof _CincoId) {
			_CincoId id = (_CincoId) obj;

			node = new IdNode(obj);
			node.setLabel(id.toString());

			MergeInformation<E, A> mergeInfo = mp.getMergeInformationMap().get(
					id);
			for (Set<ChangeModule<E, A>> conflictSet : mergeInfo
					.getListOfConflictedChangeSets()) {
				buildTreeById(conflictSet, node);
			}
			for (ChangeModule<E, A> change : mergeInfo.getLocalChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					buildTreeById(change, node);
			}
			for (ChangeModule<E, A> change : mergeInfo.getRemoteChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					buildTreeById(change, node);
			}
		}

		if (obj instanceof ChangeModule<?, ?>) {
			ChangeModule<E, A> change = (ChangeModule<E, A>) obj;
			node = new ContainerTreeNode(obj, obj.toString());
			node.setLabel(change.toString());

		}

		if (obj instanceof Set<?>) {
			node = new ContainerTreeNode(obj, obj.toString());
			node.setLabel("Conflict Set");

			Set<ChangeModule<E, A>> conflictSet = (Set<ChangeModule<E, A>>) obj;
			for (ChangeModule<E, A> change : conflictSet) {
				buildTreeById(change, node);
			}
		}

		/*
		 * post processing
		 */
		parentNode.getChildren().add(node);
		node.setParent(parentNode);

		/*
		 * TreeNode existingNode = parentNode.find(node.getId()); if
		 * (existingNode == null) { parentNode.getChildren().add(node);
		 * node.setParent(parentNode); } else { return existingNode; }
		 */

		return node;
	}

}
