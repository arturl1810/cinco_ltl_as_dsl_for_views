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
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;

public class CheckViewTreeProvider<E extends _CincoId, M extends GraphModel, W extends CGraphModel, A extends _CincoAdapter<E, M, W>> extends TreeProvider {
	private String[] fileExtensions = { "data", "sibs" };

	private CheckViewPage<E, M, W, A> page;
	
	public enum ViewType {
		BY_MODULE, BY_ID
	}

	private ContainerTreeNode byModuleRoot;
	private ContainerTreeNode byIdRoot;

	private ViewType activeView = ViewType.BY_MODULE;

	private CheckProcess<E, A> cp;
	
	public CheckViewTreeProvider(CheckViewPage<E, M, W, A> page) {
		super();
		this.page = page;
	}

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

	@Override
	public void loadData(Object rootObject) {
		
		final long timeStart = System.currentTimeMillis();
		
		cp = page.getCp();
		
		if (cp == null)
			return;
		
		cp.checkModel();
		
		switch (activeView) {
		case BY_MODULE:
			byModuleRoot = new ContainerTreeNode(null, "root");
			for (CheckModule<E, A> module : cp.getModules()) {
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
			for (CheckResult<E, A> result : cp.getCheckInformationMap().get(obj).getResults()) {
				buildTreeById(result, node);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
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
			CheckModule<E, A> module = (CheckModule<E, A>) obj;
			node = new ContainerTreeNode(obj, module.getClass().getSimpleName());
			node.setLabel(module.getClass().getSimpleName());
			for (CheckResult<E, A> result : module.getResults()) {
				buildTreeByModule(result, node);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
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

