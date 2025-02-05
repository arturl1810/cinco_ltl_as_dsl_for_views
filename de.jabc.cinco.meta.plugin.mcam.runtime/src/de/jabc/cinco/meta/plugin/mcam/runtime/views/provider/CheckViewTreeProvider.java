package de.jabc.cinco.meta.plugin.mcam.runtime.views.provider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.LinkedTransferQueue;

import de.jabc.cinco.meta.core.utils.job.CompoundJob;
import de.jabc.cinco.meta.core.utils.job.JobFactory;
import de.jabc.cinco.meta.core.utils.job.ReiteratingThread;
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry;
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
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;
import graphmodel.GraphModel;
import info.scce.mcam.framework.adapter.EntityId;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import info.scce.mcam.framework.processes.CheckResult.CheckResultType;

public class CheckViewTreeProvider<E extends _CincoId, M extends GraphModel, A extends _CincoAdapter<E, M>>
		extends TreeProvider {
	
	private CheckViewPage<E, M, A> page;
	private WorkbenchExtension workbench = new WorkbenchExtension();
	
	public enum ViewType {
		BY_MODULE, BY_ID
	}

	private ContainerTreeNode byModuleRoot = null;
	private ContainerTreeNode byIdRoot = null;
	private NonEmptyRegistry<CheckProcess<?,?>, List<TreeNode>> byModuleNodes
			= new NonEmptyRegistry<>( (cp) -> new ArrayList<>() );
	private NonEmptyRegistry<CheckProcess<?,?>, List<TreeNode>> byIdNodes
			= new NonEmptyRegistry<>( (cp) -> new ArrayList<>() );

	private ViewType activeView = ViewType.BY_ID;
	private boolean treeResortRequested = false;
	private ReiteratingThread treeRefresher = new TreeRefresher();
	private LinkedTransferQueue<CheckProcess<?,?>> treeNodeRefreshRequests = new LinkedTransferQueue<>();

	private List<CheckProcess<?, ?>> checkProcesses = new ArrayList<CheckProcess<?, ?>>();
	private CompoundJob checkJob = null;
	private boolean foundFirstError = false;

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
		if (checkJob != null && checkJob.getResult() == null) {
			checkJob.cancel();
		}

		checkProcesses = page.getCheckProcesses();
		if (checkProcesses.size() <= 0)
			return;
		
		initTree();
		
		checkJob = JobFactory.job("Validation");
		checkJob
			.consume(1)
				.task(this::preChecking)
			.consumeConcurrent(99)
				.taskForEach(checkProcesses, this::runCheckProcess)
			.onDone(this::postChecking)
			.schedule();
	}
	
	protected void initTree() {
		byModuleNodes.clear();
		byModuleRoot = new ContainerTreeNode(null, "root");
		byIdNodes.clear();
		byIdRoot = new ContainerTreeNode(null, "root");
		refreshTree();
	}

	protected void buildTree() {
		byModuleRoot = new ContainerTreeNode(null, "root");
		byIdRoot = new ContainerTreeNode(null, "root");
		TreeNode node;
		
		if (checkProcesses.size() == 1) {
			CheckProcess<?, ?> checkProcess = checkProcesses.get(0);
			for (CheckModule<?, ?> module : checkProcess.getModules()) {
				node = buildTreeByModule(module, byModuleRoot, checkProcess);
				byModuleNodes.get(checkProcess).add(node);
			}
			addDefaultOkNode(byModuleRoot);
			for (EntityId id : checkProcess.getCheckInformationMap().keySet()) {
				node = buildTreeById(id, byIdRoot, checkProcess);
				byIdNodes.get(checkProcess).add(node);
			}
			addDefaultOkNode(byIdRoot);
		} else {
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				node = buildTreeByModule(checkProcess, byModuleRoot, checkProcess);
				byModuleNodes.get(checkProcess).add(node);
				node = buildTreeById(checkProcess, byIdRoot, checkProcess);
				byIdNodes.get(checkProcess).add(node);
			}
		}
		
		refreshTree();
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

	@SuppressWarnings("restriction")
	void refreshTreeNode(CheckProcess<?, ?> checkProcess) {
		List<TreeNode> cpByModuleNodes = byModuleNodes.get(checkProcess);
		if (!cpByModuleNodes.isEmpty()) {
			workbench.async(() -> {
				for (TreeNode byModuleNode : cpByModuleNodes) {
					if (byModuleNode.getChildren().isEmpty()) {
						for (CheckModule<?, ?> module : checkProcess.getModules()) {
							buildTreeByModule(module, byModuleNode, checkProcess);
						}
					}
					page.getTreeViewer().refresh(byModuleNode);
				}
			});
		} else {
			buildTree();
		}
		
		
		List<TreeNode> cpByIdNodes = byIdNodes.get(checkProcess);
		if (!cpByIdNodes.isEmpty()) {
			workbench.async(() -> {
				for (TreeNode byIdNode : cpByIdNodes) {
					if (byIdNode.getChildren().isEmpty()) {
						for (EntityId  id : checkProcess.getCheckInformationMap().keySet()) {
							buildTreeById(id, byIdNode, checkProcess);
						}
					}
					page.getTreeViewer().refresh(byIdNode);
				}
			});
		} else {
			buildTree();
		}
	}
	
	@SuppressWarnings("restriction")
	void refreshTree() {
		workbench.async(() -> page.getTreeViewer().refresh(true));
	}
	
	@SuppressWarnings("restriction")
	void resortTree() {
		workbench.async(() -> page.getTreeViewer().refresh(false));
	}
	
	void requestTreeResort() {
		treeResortRequested = true;
		assertTreeRefresherIsAlive();
	}
	
	void requestTreeNodeRefresh(CheckProcess<?,?> checkProcess) {
		treeNodeRefreshRequests.add(checkProcess);
		assertTreeRefresherIsAlive();
	}
	
	void assertTreeRefresherIsAlive() {
		if (!treeRefresher.isStarted()) {
			treeRefresher.start();
		} else {
			treeRefresher.unpause();
		}
	}
	
	boolean hasError(CheckProcess<?, ?> checkProcess) {
		for (CheckModule<?, ?> module : checkProcess.getModules()) {
			if (module.hasResultOfType(CheckResultType.ERROR)) {
				return true;
			}
		}
		return false;
	}
	
	void preChecking() {
		foundFirstError = false;
		treeResortRequested = false;
	}
	
	void runCheckProcess(CheckProcess<?,?> checkProcess) {
		if (foundFirstError && page.getCheckConfiguration().isStopAtFirstError()) {
			return;
		}
		checkProcess.checkModel();
		requestTreeNodeRefresh(checkProcess);
		if (hasError(checkProcess)) {
			foundFirstError = true;
			requestTreeResort();
		}
	}
	
	void postChecking() {
		requestTreeResort();
	}
	
	class TreeRefresher extends ReiteratingThread {
		
		public TreeRefresher() {
			super(500);
		}
		
		@Override
		protected void work() {
			CheckProcess<?,?> checkProcess = treeNodeRefreshRequests.poll();
			if (checkProcess == null && !treeResortRequested) {
				pause();
				return;
			}
			while (checkProcess != null) {
				refreshTreeNode(checkProcess);
				checkProcess = treeNodeRefreshRequests.poll();
			}
			if (treeResortRequested) {
				treeResortRequested = false;
				resortTree();
			}
		}
	}
}
