package de.jabc.cinco.meta.plugin.mcam.runtime.views.pages;

import graphicalgraphmodel.CGraphModel;
import graphmodel.GraphModel;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import info.scce.mcam.framework.processes.CheckResult.CheckResultType;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.viewers.ViewerSorter;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.CheckViewTreeProvider;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public abstract class CheckViewPage<E extends _CincoId, M extends GraphModel, W extends CGraphModel, A extends _CincoAdapter<E, M, W>>
		extends McamPage {

	private CheckViewTreeProvider<E, M, W, A> data;

	// protected IFile iFile;
	// protected Resource resource;

	// private List<CheckProcess<E, A>> checkProcesses = new
	// ArrayList<CheckProcess<E, A>>();
	private List<CheckProcess<?, ?>> checkProcesses = new ArrayList<CheckProcess<?, ?>>();

	private HashMap<String, Image> icons = new HashMap<>();

	private CheckViewLabelProvider labelProvider = new CheckViewLabelProvider();
	private CheckViewNameSorter nameSorter = new CheckViewNameSorter();

	private CheckViewResultTypeFilter resultTypeFilter = new CheckViewResultTypeFilter();

	public CheckViewPage(String pageId) {
		super(pageId);
		// this.iFile = iFile;
		// this.resource = resource;

		// this.cp = createCp();
		this.data = new CheckViewTreeProvider<E, M, W, A>(this);
	}

	/*
	 * Getter / Setter
	 */
	// public IFile getiFile() {
	// return iFile;
	// }

	public List<CheckProcess<?, ?>> getCheckProcesses() {
		return checkProcesses;
	}

	// public Resource getResource() {
	// return resource;
	// }

	@Override
	public CheckViewTreeProvider<E, M, W, A> getDataProvider() {
		return data;
	}

	@Override
	public LabelProvider getDefaultLabelProvider() {
		return labelProvider;
	}

	@Override
	public ViewerSorter getDefaultSorter() {
		return nameSorter;
	}

	/*
	 * Methods
	 */
	@Override
	protected void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.runtime");
		try {
			InputStream entityOkImgStream = FileLocator.openStream(bundle,
					new Path("icons/ok.png"), true);
			icons.put("resultOk", new Image(EclipseUtils.getDisplay(),
					entityOkImgStream));
			InputStream entityErrorImgStream = FileLocator.openStream(bundle,
					new Path("icons/error.png"), true);
			icons.put("resultError", new Image(EclipseUtils.getDisplay(),
					entityErrorImgStream));
			InputStream checkWarningImgStream = FileLocator.openStream(bundle,
					new Path("icons/warning.png"), true);
			icons.put("resultWarning", new Image(EclipseUtils.getDisplay(),
					checkWarningImgStream));
			InputStream checkNotCheckedImgStream = FileLocator.openStream(
					bundle, new Path("icons/info.png"), true);
			icons.put("resultNotChecked", new Image(EclipseUtils.getDisplay(),
					checkNotCheckedImgStream));
			InputStream checkInfoImgStream = FileLocator.openStream(bundle,
					new Path("icons/info.png"), true);
			icons.put("resultInfo", new Image(EclipseUtils.getDisplay(),
					checkInfoImgStream));
			InputStream checkFailureImgStream = FileLocator.openStream(bundle,
					new Path("icons/failure.png"), true);
			icons.put("resultFailure", new Image(EclipseUtils.getDisplay(),
					checkFailureImgStream));
			InputStream checkItemImgStream = FileLocator.openStream(bundle,
					new Path("icons/item.png"), true);
			icons.put("item", new Image(EclipseUtils.getDisplay(),
					checkItemImgStream));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public abstract void addCheckProcess(IFile iFile, Resource resource);

	@Override
	public void reload() {
		storeTreeState();
		// this.cp = createCp();
		data.reset();
		treeViewer.setInput(parentViewPart.getViewSite());
		restoreTreeState();
	}

	@SuppressWarnings("unchecked")
	@Override
	public void highlight(Object obj) {
		Object element = obj;
		if (obj instanceof TreeNode)
			element = getTreeNodeData(obj);

		if (element instanceof CheckResult<?, ?>) {
			CheckResult<E, A> result = (CheckResult<E, A>) element;

			result.getModule().getCp().getModel()
					.highlightElement((E) result.getId());
		}
		if (element instanceof _CincoId) {
			_CincoId id = (E) element;
			CheckProcess<?, ?> checkProcess = getCheckProcessById(id);
			((_CincoAdapter<E, M, W>) checkProcess.getModel())
					.highlightElement((E) element);
		}
	}

	protected CheckProcess<?, ?> getCheckProcessById(_CincoId id) {
		for (CheckProcess<?, ?> checkProcess : checkProcesses) {
			if (checkProcess.getModel().getEntityIds().contains(id))
				return checkProcess;
		}
		return null;
	}

	@Override
	public void initPage(Composite parent, ViewPart parentViewPart)
			throws IOException {
		super.initPage(parent, parentViewPart);
		// treeViewer.addFilter(resultTypeFilter);
	}

	/*
	 * Provider / Classes for TreeViewer
	 */
	private class CheckViewLabelProvider extends LabelProvider {

		public String getText(Object obj) {
			// Object element = getTreeNodeData(obj);
			if (obj instanceof TreeNode) {
				return ((TreeNode) obj).getLabel();
			}
			return "unknown";
		}

		@SuppressWarnings("unchecked")
		public Image getImage(Object obj) {
			Object element = getTreeNodeData(obj);
			if (element instanceof CheckResult<?, ?>) {
				CheckResult<E, A> result = (CheckResult<E, A>) element;
				return mapResultTypeToImage(result.getType());
			}
			if (element instanceof CheckModule<?, ?>) {
				CheckModule<E, A> module = (CheckModule<E, A>) element;
				return mapResultTypeToImage(module.getResultType());
			}
			if (element instanceof _CincoId) {
				CheckProcess<?, ?> cp = getCheckProcessById((_CincoId) element);
				return mapResultTypeToImage(cp.getCheckInformationMap().get(element).getResultType());
				//return icons.get("item");
			}
			return null;
		}

		private Image mapResultTypeToImage(CheckResultType type) {
			if (type.equals(CheckResultType.PASSED))
				return icons.get("resultOk");
			if (type.equals(CheckResultType.ERROR))
				return icons.get("resultError");
			if (type.equals(CheckResultType.WARNING))
				return icons.get("resultWarning");
			if (type.equals(CheckResultType.NOT_CHECKED))
				return icons.get("resultNotChecked");
			if (type.equals(CheckResultType.INFO))
				return icons.get("resultInfo");
			if (type.equals(CheckResultType.FAILURE))
				return icons.get("resultFailure");
			return null;
		}
	}

	private class CheckViewNameSorter extends ViewerSorter {

		private ArrayList<CheckResultType> typeSorting = new ArrayList<>();

		public CheckViewNameSorter() {
			super();
			typeSorting.add(CheckResultType.FAILURE);
			typeSorting.add(CheckResultType.ERROR);
			typeSorting.add(CheckResultType.WARNING);
			typeSorting.add(CheckResultType.INFO);
			typeSorting.add(CheckResultType.PASSED);
			typeSorting.add(CheckResultType.NOT_CHECKED);
		}

		@Override
		public int category(Object element) {
			if (element instanceof _CincoId)
				return 1;
			return 3;
		}

		@SuppressWarnings("unchecked")
		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {
			e1 = getTreeNodeData(e1);
			e2 = getTreeNodeData(e2);

			int cat1 = category(e1);
			int cat2 = category(e2);
			if (cat1 != cat2)
				return cat1 - cat2;

			if (e1 instanceof CheckModule && e2 instanceof CheckModule) {
				CheckModule<E, A> cm1 = (CheckModule<E, A>) e1;
				CheckModule<E, A> cm2 = (CheckModule<E, A>) e2;
				return typeSorting.indexOf(cm1.getResultType())
						- typeSorting.indexOf(cm2.getResultType());
			}

			if (e1 instanceof CheckResult && e2 instanceof CheckResult) {
				CheckResult<E, A> result1 = (CheckResult<E, A>) e1;
				CheckResult<E, A> result2 = (CheckResult<E, A>) e2;
				return typeSorting.indexOf(result1.getType())
						- typeSorting.indexOf(result2.getType());
			}

			if (e1 instanceof _CincoId && e2 instanceof _CincoId) {
				E id1 = (E) e1;
				E id2 = (E) e2;
				return id1.toString().compareTo(id2.toString());
			}

			return super.compare(viewer, e1, e2);
		}

	}

	private class CheckViewResultTypeFilter extends ViewerFilter {

		private ArrayList<CheckResultType> types = new ArrayList<CheckResultType>();

		public CheckViewResultTypeFilter() {
			super();

			types.add(CheckResultType.ERROR);
			types.add(CheckResultType.FAILURE);
			types.add(CheckResultType.INFO);
			types.add(CheckResultType.NOT_CHECKED);
			types.add(CheckResultType.PASSED);
			types.add(CheckResultType.WARNING);
		}

		@Override
		public boolean select(Viewer viewer, Object parentElement,
				Object element) {

			if (element instanceof TreeNode) {
				TreeNode node = (TreeNode) element;
				if (display(node.getData()))
					return true;
				for (TreeNode childNode : node.getChildren()) {
					return select(viewer, element, childNode);
				}
			}

			return false;
		}

		@SuppressWarnings("unchecked")
		private boolean display(Object element) {
			if (element instanceof CheckResult<?, ?>) {
				CheckResult<E, A> result = (CheckResult<E, A>) element;
				if (types.contains(result.getType()))
					return true;
			}
			return false;
		}

	}

}
