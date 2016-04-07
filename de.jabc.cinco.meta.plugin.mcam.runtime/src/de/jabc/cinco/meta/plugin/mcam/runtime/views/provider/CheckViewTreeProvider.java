package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import graphicalgraphmodel.CGraphModel;
import graphmodel.GraphModel;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.ContainerTreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.IdNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;

public class CheckViewTreeProvider<E extends _CincoId, M extends GraphModel, W extends CGraphModel> extends TreeProvider {
	private String[] fileExtensions = { "data", "sibs" };

	public enum ViewType {
		BY_MODULE, BY_ID
	}

	private ContainerTreeNode byModuleRoot;
	private ContainerTreeNode byIdRoot;

	private ViewType activeView = ViewType.BY_ID;

	private CheckProcess<E, _CincoAdapter<E, M, W>> cp;

	@Override
	public TreeNode getTree() {
		switch (activeView) {
		case BY_MODULE:
			return byModuleRoot;
		case BY_ID:
		default:
			return byIdRoot;
		}
	}

	public String[] getFileExtensions() {
		return fileExtensions;
	}

	public ViewType getActiveView() {
		return activeView;
	}

	public void setActiveView(ViewType activeView) {
		this.activeView = activeView;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void loadData(Object rootObject) {
		
		if (rootObject == null)
			return;
		
		final long timeStart = System.currentTimeMillis();
		
		cp = (CheckProcess<E, _CincoAdapter<E, M, W>>) rootObject;
		cp.checkModel();
		
		switch (activeView) {
		case BY_MODULE:
			byModuleRoot = new ContainerTreeNode(null, "root");
			for (CheckModule<E, _CincoAdapter<E, M, W>> module : cp.getModules()) {
				buildTreeByModule(module, byModuleRoot);
			}
			break;
		case BY_ID:
		default:
			byIdRoot = new ContainerTreeNode(null, "root");
			for (_CincoId id : cp.getCheckInformationMap().keySet()) {
				buildTreeById(id, byIdRoot);
			}
			break;
		}
		System.out.println("CheckView - create Tree: " + (System.currentTimeMillis() - timeStart) + " ms");
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeById(Object obj, TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(null, "dummy");
		
		if (obj instanceof _CincoId) {
			node = new IdNode(obj);
			node.setLabel(((_CincoId) obj).toString());
			for (CheckResult<E, _CincoAdapter<E, M, W>> result : cp.getCheckInformationMap().get(obj).getResults()) {
				buildTreeById(result, node);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, _CincoAdapter<E, M, W>> result = (CheckResult<E, _CincoAdapter<E, M, W>>) obj;
			node = new ContainerTreeNode(obj, result.getUUID().toString());
			node.setLabel("[" + result.getModule().getClass().getSimpleName() + "] " + result.getMessage());
		}
		
		/*
		 * post processing
		 */
		TreeNode existingNode = parentNode.find(node.getId());
		if (existingNode == null) {
			parentNode.getChildren().add(node);
			node.setParent(parentNode);
		} else {
			return existingNode;
		}
		return node;
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeByModule(Object obj, TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(null, "dummy");
		
		if (obj instanceof CheckModule<?, ?>) {
			CheckModule<E, _CincoAdapter<E, M, W>> module = (CheckModule<E, _CincoAdapter<E, M, W>>) obj;
			node = new ContainerTreeNode(obj, module.getClass().getSimpleName());
			node.setLabel(module.getClass().getSimpleName());
			for (CheckResult<E, _CincoAdapter<E, M, W>> result : module.getResults()) {
				buildTreeByModule(result, node);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, _CincoAdapter<E, M, W>> result = (CheckResult<E, _CincoAdapter<E, M, W>>) obj;
			node = new ContainerTreeNode(obj, result.getUUID().toString());
			node.setLabel(result.getId().toString() + ": " + result.getMessage());
		}
		
		/*
		 * post processing
		 */
		TreeNode existingNode = parentNode.find(node.getId());
		if (existingNode == null) {
			parentNode.getChildren().add(node);
			node.setParent(parentNode);
		} else {
			return existingNode;
		}
		return node;
	}

}

