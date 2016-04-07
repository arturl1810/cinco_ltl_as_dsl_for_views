package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import graphicalgraphmodel.CGraphModel;
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

public class ConflictViewTreeProvider<E extends _CincoId, M extends GraphModel, W extends CGraphModel> extends TreeProvider {

	public enum ViewType {
		BY_ID
	}

	private ContainerTreeNode byIdRoot;

	private ViewType activeView = ViewType.BY_ID;

	private MergeProcess<E, _CincoAdapter<E, M, W>> mp;

	@Override
	public TreeNode getTree() {
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

	public MergeProcess<E, _CincoAdapter<E, M, W>> getMergeProcess() {
		return mp;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void loadData(Object rootObject) {
		if (rootObject == null)
			return;
		
		final long timeStart = System.currentTimeMillis();
		
		mp = (MergeProcess<E, _CincoAdapter<E, M, W>>) rootObject;

		switch (activeView) {
		case BY_ID:
		default:
			byIdRoot = new ContainerTreeNode(null, "root");
			for (MergeInformation<E, _CincoAdapter<E, M, W>> mergeInfo : mp.getMergeInformationMap().values()) {
				if (mergeInfo.getLocalChanges().size() > 0 || mergeInfo.getRemoteChanges().size() > 0)
					buildTreeById(mergeInfo.getId(), byIdRoot);
			}
			break;
		}
		System.out.println("ConflictView - create Tree: " + (System.currentTimeMillis() - timeStart) + " ms");
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeById(Object obj, TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(null, "dummy");
		
		if(obj instanceof _CincoId) {
			_CincoId id = (_CincoId) obj;
			
			node = new IdNode(obj);
			node.setLabel(id.toString());

			MergeInformation<E, _CincoAdapter<E, M, W>> mergeInfo = mp.getMergeInformationMap().get(id);
			for (Set<ChangeModule<E, _CincoAdapter<E, M, W>>> conflictSet : mergeInfo.getListOfConflictedChangeSets()) {
				buildTreeById(conflictSet, node);
			}
			for (ChangeModule<E, _CincoAdapter<E, M, W>> change : mergeInfo.getLocalChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					buildTreeById(change, node);
			}
			for (ChangeModule<E, _CincoAdapter<E, M, W>> change : mergeInfo.getRemoteChanges()) {
				if (!mergeInfo.isConflictedChange(change))
					buildTreeById(change, node);
			}
		}

		if (obj instanceof ChangeModule<?, ?>) {
			ChangeModule<E, _CincoAdapter<E, M, W>> change = (ChangeModule<E, _CincoAdapter<E, M, W>>) obj;		
			node = new ContainerTreeNode(obj, obj.toString());
			node.setLabel(change.toString());

		}



		if (obj instanceof Set<?>) {
			node = new ContainerTreeNode(obj, obj.toString());
			node.setLabel("Conflict Set");

			Set<ChangeModule<E, _CincoAdapter<E, M, W>>> conflictSet = (Set<ChangeModule<E, _CincoAdapter<E, M, W>>>) obj;
			for (ChangeModule<E, _CincoAdapter<E, M, W>> change : conflictSet) {
				buildTreeById(change, node);
			}
		}

		
		/*
		 * post processing
		 */
		parentNode.getChildren().add(node);
		node.setParent(parentNode);

		/*
		TreeNode existingNode = parentNode.find(node.getId());
		if (existingNode == null) {
			parentNode.getChildren().add(node);
			node.setParent(parentNode);
		} else {
			return existingNode;
		}
		*/

		return node;
	}


}

