package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import java.util.ArrayList;
import java.util.List;

import graphmodel.GraphModel;
import info.scce.mcam.framework.adapter.EntityId;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import info.scce.mcam.framework.processes.CheckResult.CheckResultType;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.CheckModuleNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.CheckProcessNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.CheckResultNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.ContainerTreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.DefaultOkObject;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.IdNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;

public class CheckViewTreeProvider<E extends _CincoId, M extends GraphModel, A extends _CincoAdapter<E, M>>
		extends TreeProvider {
	private CheckViewPage<E, M, A> page;

	public enum ViewType {
		BY_MODULE, BY_ID
	}

	private ContainerTreeNode byModuleRoot = null;
	private ContainerTreeNode byIdRoot = null;

	private ViewType activeView = ViewType.BY_ID;

	private List<CheckProcess<?, ?>> checkProcesses = new ArrayList<CheckProcess<?, ?>>();

	public CheckViewTreeProvider(CheckViewPage<E, M, A> page, ViewType vType) {
		super();
		this.page = page;
		this.activeView = vType;
	}

	@Override
	protected TreeNode getTreeRoot() {
		switch (activeView) {
		case BY_MODULE:
			return byModuleRoot;
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

	@Override
	protected void loadData(Object rootObject) {
		System.out.println("["+getClass().getSimpleName()+"] loadData");
		final long timeStart = System.currentTimeMillis();

		checkProcesses = page.getCheckProcesses();
		if (checkProcesses.size() <= 0)
			return;
		
		boolean stopAtFirstError = page.getCheckConfiguration().isStopAtFirstError();
		boolean foundFirstError = false;
		for (CheckProcess<?, ?> checkProcess : checkProcesses) {
			System.out.println("["+getClass().getSimpleName()+"] loadData > checkProcess: " + checkProcess.getModel().getModelName());
			checkProcess.checkModel();
			for (CheckModule<?, ?> module : checkProcess.getModules()) {
				if (module.hasResultOfType(CheckResultType.ERROR)) {
					System.out.println("["+getClass().getSimpleName()+"] loadData > checkProcess > CheckResult is ERROR -> STOP! ");
					foundFirstError = true;
				}
			}
			if (stopAtFirstError && foundFirstError) {
				System.out.println("["+getClass().getSimpleName()+"] loadData > stop at first error ");
				break;
			}
		}
		
		final long timeLoad = System.currentTimeMillis();

		buildTree();
		final long timeBuild = System.currentTimeMillis();

		System.out.println(page.getClass().getSimpleName()
				+ " - load: " + (timeLoad - timeStart)
				+ " ms / build: " + (timeBuild - timeLoad) + " ms");
	}

	protected void buildTree() {
		byModuleRoot = new ContainerTreeNode(null, "root");
		if (checkProcesses.size() == 1) {
			for (CheckModule<?, ?> module : checkProcesses.get(0).getModules()) {
				buildTreeByModule(module, byModuleRoot, checkProcesses.get(0));
			}
			addDefaultOkNode(byModuleRoot);
		} else {
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				buildTreeByModule(checkProcess, byModuleRoot, checkProcess);
			}
		}

		byIdRoot = new ContainerTreeNode(null, "root");
		if (checkProcesses.size() == 1) {
			for (EntityId id : checkProcesses.get(0).getCheckInformationMap().keySet()) {
				buildTreeById(id, byIdRoot, checkProcesses.get(0));
			}
			addDefaultOkNode(byIdRoot);
		} else {
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				buildTreeById(checkProcess, byIdRoot, checkProcess);
			}
		}
	}
	
	protected void addDefaultOkNode(TreeNode parentNode) {
		TreeNode node = new ContainerTreeNode(new DefaultOkObject(), "defaultOK");
		findExistingNode(node, parentNode);
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeById(Object obj, TreeNode parentNode,
			CheckProcess<?, ?> checkProcess) {
		TreeNode node = new ContainerTreeNode(null, "dummy");

		if (obj instanceof CheckProcess) {
			node = new CheckProcessNode(obj);
			CheckProcess<?, ?> cp = (CheckProcess<?, ?>) obj;
			node.setLabel(cp.getModel().getModelName());
			node = findExistingNode(node, parentNode);
			for (EntityId id : checkProcess.getCheckInformationMap().keySet()) {
				buildTreeById(id, node, cp);
			}
		}

		if (obj instanceof _CincoId) {
			node = new IdNode(obj);
			node.setLabel(((_CincoId) obj).toString());
			node = findExistingNode(node, parentNode);
			for (CheckResult<?, ?> result : checkProcess
					.getCheckInformationMap().get(obj).getResults()) {
				buildTreeById(result, node, checkProcess);
			}
		}

		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
			node = new CheckResultNode(result);
			node.setLabel("[" + result.getModule().getName()
					+ "] " + result.getMessage());
			node = findExistingNode(node, parentNode);
		}

		return node;
	}

	@SuppressWarnings("unchecked")
	private TreeNode buildTreeByModule(Object obj, TreeNode parentNode,
			CheckProcess<?, ?> checkProcess) {
		TreeNode node = new ContainerTreeNode(null, "dummy");

		if (obj instanceof CheckProcess) {
			node = new CheckProcessNode(obj);
			CheckProcess<?, ?> cp = (CheckProcess<?, ?>) obj;
			node.setLabel(cp.getModel().getModelName());
			node = findExistingNode(node, parentNode);
			for (CheckModule<?, ?> module : checkProcess.getModules()) {
				buildTreeByModule(module, node, cp);
			}
		}

		if (obj instanceof CheckModule<?, ?>) {
			CheckModule<E, A> module = (CheckModule<E, A>) obj;
			node = new CheckModuleNode(obj);
			node.setLabel(module.getName());
			node = findExistingNode(node, parentNode);
			for (CheckResult<E, A> result : module.getResults()) {
				buildTreeByModule(result, node, checkProcess);
			}
		}

		if (obj instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) obj;
			node = new CheckResultNode(result);
			String id =
				result.getId() != null
					? result.getId().toString()
					: "null";
			node.setLabel(id + ": " + result.getMessage());
			node = findExistingNode(node, parentNode);
		}

		return node;
	}

}
