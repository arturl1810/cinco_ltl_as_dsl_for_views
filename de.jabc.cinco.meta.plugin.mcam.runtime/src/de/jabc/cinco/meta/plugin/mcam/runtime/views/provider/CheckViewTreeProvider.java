package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import java.util.ArrayList;
import java.util.List;

import graphicalgraphmodel.CGraphModel;
import graphmodel.GraphModel;
import info.scce.mcam.framework.adapter.EntityId;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.CheckResultNode;
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

	private ViewType activeView = ViewType.BY_ID;

	private List<CheckProcess<?, ?>> checkProcesses = new ArrayList<CheckProcess<?, ?>>();
	
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
		
		checkProcesses = page.getCheckProcesses();
		
		if (checkProcesses.size() <= 0)
			return;
		
		for (CheckProcess<?, ?> checkProcess : checkProcesses) {
			checkProcess.checkModel();
		}
		
		final long timeLoad = System.currentTimeMillis();
		
		switch (activeView) {
		case BY_MODULE:
			byModuleRoot = new ContainerTreeNode(null, "root");
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				for (CheckModule<?, ?> module : checkProcess.getModules()) {
					buildTreeByModule(module, byModuleRoot, checkProcess);
				}
			}
			break;
		case BY_ID:
		default:
			byIdRoot = new ContainerTreeNode(null, "root");
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				for (EntityId id : checkProcess.getCheckInformationMap().keySet()) {
					buildTreeById(id, byIdRoot, checkProcess);
				}
			}
			break;
		}
		final long timeBuild = System.currentTimeMillis();
		
		System.out.println("CheckView - load: " + (timeLoad - timeStart) + " ms / build: " + (timeBuild - timeLoad) + " ms");
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeById(Object obj, TreeNode parentNode, CheckProcess<?, ?> checkProcess) {
		TreeNode node = new ContainerTreeNode(null, "dummy");
		
		if (obj instanceof _CincoId) {
			node = new IdNode(obj);
			node.setLabel(((_CincoId) obj).toString());
			node = findExistingNode(node, parentNode);
			for (CheckResult<?, ?> result : checkProcess.getCheckInformationMap().get(obj).getResults()) {
				buildTreeById(result, node, checkProcess);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
			node = new CheckResultNode(result);
			node.setLabel("[" + result.getModule().getClass().getSimpleName() + "] " + result.getMessage());
			node = findExistingNode(node, parentNode);
		}
		
		return node;
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeByModule(Object obj, TreeNode parentNode, CheckProcess<?, ?> checkProcess) {
		TreeNode node = new ContainerTreeNode(null, "dummy");
		
		if (obj instanceof CheckModule<?, ?>) {
			CheckModule<E, A> module = (CheckModule<E, A>) obj;
			node = new ContainerTreeNode(obj, module.getClass().getSimpleName());
			node.setLabel(module.getClass().getSimpleName());
			node = findExistingNode(node, parentNode);
			for (CheckResult<E, A> result : module.getResults()) {
				buildTreeByModule(result, node, checkProcess);
			}
		}
		
		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
			node = new CheckResultNode(result);
			node.setLabel(result.getId().toString() + ": " + result.getMessage());
			node = findExistingNode(node, parentNode);
		}
		
		return node;
	}

}

