package de.jabc.cinco.meta.plugin.mcam.runtime.views.pages;

import graphmodel.GraphModel;
import graphmodel.ModelElement;
import info.scce.mcam.framework.modules.CheckModule;
import info.scce.mcam.framework.processes.CheckInformation;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CheckResult;
import info.scce.mcam.framework.processes.CheckResult.CheckResultType;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider.IStyledLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.StyledString;
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
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.DefaultOkObject;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.CheckViewTreeProvider;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.CheckViewTreeProvider.ViewType;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public abstract class CheckViewPage<E extends _CincoId, M extends GraphModel, A extends _CincoAdapter<E, M>>
		extends McamPage {

	private CheckViewTreeProvider<E, M, A> data;

	private List<CheckProcess<?, ?>> checkProcesses = new ArrayList<CheckProcess<?, ?>>();

	private HashMap<String, Image> icons = new HashMap<>();

	private CheckViewLabelProvider labelProvider = new CheckViewLabelProvider();
	private CheckViewNameSorter nameSorter = new CheckViewNameSorter();

	private CheckViewResultTypeFilter resultTypeFilter = new CheckViewResultTypeFilter();
	private DefaultOkResultFilter defaultOkResultFilter = new DefaultOkResultFilter();

	public CheckViewPage(String pageId) {
		super(pageId);
		this.data = new CheckViewTreeProvider<E, M, A>(this, ViewType.BY_ID);
	}

	/*
	 * Getter / Setter
	 */
	public List<CheckProcess<?, ?>> getCheckProcesses() {
		return checkProcesses;
	}

	@Override
	public CheckViewTreeProvider<E, M, A> getDataProvider() {
		return data;
	}

	@Override
	public DelegatingStyledCellLabelProvider getDefaultLabelProvider() {
		return new DelegatingStyledCellLabelProvider(labelProvider);
		// return labelProvider;
	}

	public CheckViewLabelProvider getLabelProvider() {
		return labelProvider;
	}

	@Override
	public ViewerSorter getDefaultSorter() {
		return nameSorter;
	}

	public CheckViewResultTypeFilter getResultTypeFilter() {
		return resultTypeFilter;
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
			((_CincoAdapter<E, M>) checkProcess.getModel())
					.highlightElement((E) element);
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void openAndHighlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof _CincoId)
			openAndHighlight((_CincoId) obj);
		if (obj instanceof CheckResult)
			openAndHighlight(((CheckResult<E, A>) obj).getId());
		if (obj instanceof CheckProcess)
			openEditor(((CheckProcess<E, A>) obj).getModel().getModel());
	}

	@SuppressWarnings("unchecked")
	protected void openAndHighlight(_CincoId id) {
		Object element = id.getElement();

		if (element instanceof ModelElement) {
			ModelElement me = (ModelElement) element;
			IEditorPart editor = openEditor(me.getRootElement());

			IFile iFile = EclipseUtils.getIFile(editor);
			Resource resource = EclipseUtils.getResource(editor);

			_CincoAdapter<E, M> adapter = getAdapter(iFile, resource);
			adapter.highlightElement(adapter.getIdByString(me.getId()));
		}
		if (element instanceof GraphModel) {
			openEditor((GraphModel) element);
		}
	}

	protected CheckProcess<?, ?> getCheckProcessById(_CincoId id) {
		for (CheckProcess<?, ?> checkProcess : checkProcesses) {
			if (checkProcess.getModel().getEntityIds().contains(id))
				return checkProcess;
		}
		return null;
	}

	protected CheckResultType getResultType(Class<?> moduleClass) {
		CheckResultType type = CheckResultType.NOT_CHECKED;
		for (CheckProcess<?, ?> checkProcess : checkProcesses) {
			for (CheckModule<?, ?> module : checkProcess.getModules()) {
				if (module.getClass().equals(moduleClass)) {
					if (compareResultType(module.getResultType(), type) < 0)
						type = module.getResultType();
				}
			}
		}
		return type;
	}

	protected CheckResultType getResultType(CheckProcess<?, ?> cp) {
		CheckResultType type = CheckResultType.NOT_CHECKED;
		for (CheckModule<?, ?> module : cp.getModules()) {
			if (compareResultType(module.getResultType(), type) < 0)
				type = module.getResultType();
		}
		return type;
	}

	protected int compareResultType(CheckResultType type1, CheckResultType type2) {
		return CheckResultType.valueOf(type1.toString()).ordinal()
				- CheckResultType.valueOf(type2.toString()).ordinal();
	}

	@Override
	public void initPage(Composite parent, ViewPart parentViewPart)
			throws IOException {
		super.initPage(parent, parentViewPart);
		treeViewer.addFilter(resultTypeFilter);
		treeViewer.addFilter(defaultOkResultFilter);
	}

	/*
	 * Provider / Classes for TreeViewer
	 */
	public class CheckViewLabelProvider extends LabelProvider implements
			IStyledLabelProvider {

		private boolean showPerformance = false;

		public boolean isShowPerformance() {
			return showPerformance;
		}

		public void setShowPerformance(boolean showPerformance) {
			this.showPerformance = showPerformance;
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
				// return
				// mapResultTypeToImage(getResultType(module.getClass()));
			}
			if (element instanceof _CincoId) {
				CheckProcess<?, ?> cp = getCheckProcessById((_CincoId) element);
				return mapResultTypeToImage(cp.getCheckInformationMap()
						.get(element).getResultType());
			}
			if (element instanceof CheckProcess) {
				CheckProcess<?, ?> cp = (CheckProcess<?, ?>) element;
				return mapResultTypeToImage(getResultType(cp));
			}
			if (element instanceof DefaultOkObject)
				return icons.get("resultOk");
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

		@SuppressWarnings("unchecked")
		@Override
		public StyledString getStyledText(Object obj) {
			StyledString styledString = new StyledString("unknown");

			if (obj instanceof TreeNode == false)
				return styledString;

			styledString = new StyledString(((TreeNode) obj).getLabel());
			// styledString.append(" (" + ((TreeNode) obj).getPathIdentifier() +
			// ") ", StyledString.DECORATIONS_STYLER);

			Object element = getTreeNodeData(obj);
			if (element instanceof CheckModule<?, ?>) {
				CheckModule<E, A> module = (CheckModule<E, A>) element;
				styledString.append(" ("
						// + checkInfo.getNumberOf(CheckResultType.FAILURE) +
						// "/"
						+ module.getNumberOf(CheckResultType.ERROR) + "/"
						+ module.getNumberOf(CheckResultType.WARNING) + ") ",
						StyledString.COUNTER_STYLER);
				if (showPerformance)
					styledString.append(" [" + module.getExecutionTime()
							+ "ms] ", StyledString.QUALIFIER_STYLER);
			}
			if (element instanceof _CincoId) {
				CheckProcess<?, ?> cp = getCheckProcessById((_CincoId) element);
				CheckInformation<?, ?> checkInfo = cp.getCheckInformationMap()
						.get(element);
				styledString.append(
						" ("
								// +
								// checkInfo.getNumberOf(CheckResultType.FAILURE)
								// + "/"
								+ checkInfo.getNumberOf(CheckResultType.ERROR)
								+ "/"
								+ checkInfo
										.getNumberOf(CheckResultType.WARNING)
								+ ") ", StyledString.COUNTER_STYLER);
			}
			if (element instanceof CheckProcess) {
				CheckProcess<?, ?> cp = (CheckProcess<?, ?>) element;
				if (showPerformance)
					styledString.append(" [" + cp.getExecutionTime() + "ms] ",
							StyledString.QUALIFIER_STYLER);
			}
			if (element instanceof DefaultOkObject) {
				return new StyledString("all checks passed!");
			}
			return styledString;
		}
	}

	private class CheckViewNameSorter extends ViewerSorter {

		public CheckViewNameSorter() {
			super();
		}

		@Override
		public int category(Object element) {
			if (element instanceof _CincoId)
				return 1;
			if (element instanceof CheckResult)
				return 2;
			if (element instanceof CheckModule)
				return 2;
			if (element instanceof CheckProcess)
				return 4;
			return 5;
		}

		@SuppressWarnings("unchecked")
		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {

			if (e1 instanceof String && e2 instanceof String) {
				String s1 = (String) e1;
				String s2 = (String) e2;
				return s1.toLowerCase().compareTo(s2.toLowerCase());
			}

			if (e1 instanceof TreeNode == false
					&& e2 instanceof TreeNode == false)
				return 0;

			TreeNode node1 = (TreeNode) e1;
			TreeNode node2 = (TreeNode) e2;

			e1 = getTreeNodeData(node1);
			e2 = getTreeNodeData(node2);

			int cat1 = category(e1);
			int cat2 = category(e2);
			if (cat1 != cat2)
				return cat1 - cat2;

			if (e1 instanceof CheckProcess && e2 instanceof CheckProcess) {
				CheckProcess<E, A> cp1 = (CheckProcess<E, A>) e1;
				CheckProcess<E, A> cp2 = (CheckProcess<E, A>) e2;
				int diff = compareResultType(getResultType(cp1),
						getResultType(cp2));
				if (diff == 0)
					return compare(viewer, cp1.getModel().getModelName(), cp2
							.getModel().getModelName());
				else
					return diff;
			}

			if (e1 instanceof CheckModule && e2 instanceof CheckModule) {
				CheckModule<E, A> cm1 = (CheckModule<E, A>) e1;
				CheckModule<E, A> cm2 = (CheckModule<E, A>) e2;
				int diff = compareResultType(cm1.getResultType(),
						cm2.getResultType());
				if (diff == 0)
					return compare(viewer, cm1.getName(), cm2
							.getName());
				else
					return diff;
			}

			if (e1 instanceof CheckResult && e2 instanceof CheckResult) {
				CheckResult<E, A> result1 = (CheckResult<E, A>) e1;
				CheckResult<E, A> result2 = (CheckResult<E, A>) e2;
				int diff = compareResultType(result1.getType(),
						result2.getType());
				if (diff == 0)
					return compare(viewer, result1.getMessage(),
							result2.getMessage());
				else
					return diff;
			}

			if (e1 instanceof _CincoId && e2 instanceof _CincoId) {
				E id1 = (E) e1;
				E id2 = (E) e2;

				CheckProcess<?, ?> cp1 = getCheckProcessById(id1);
				CheckProcess<?, ?> cp2 = getCheckProcessById(id2);

				CheckResultType type1 = cp1.getCheckInformationMap().get(id1)
						.getResultType();
				CheckResultType type2 = cp2.getCheckInformationMap().get(id2)
						.getResultType();

				int diff = compareResultType(type1, type2);
				if (diff == 0)
					return compare(viewer, id1.toString(), id2.toString());
				else
					return diff;
			}

			return super.compare(viewer, e1, e2);
		}
	}
	
	public class DefaultOkResultFilter extends ViewerFilter {

		@Override
		public boolean select(Viewer viewer, Object parentElement,
				Object element) {
			
			if (element instanceof TreeNode) {
				TreeNode node = (TreeNode) element;
				if (node.getData() instanceof DefaultOkObject == false)
					return true;
			}
			
			if (!getDataProvider().getActiveView().equals(ViewType.BY_ID))
				return false;
			
			for (CheckProcess<?, ?> checkProcess : checkProcesses) {
				for (CheckInformation<?, ?> checkInfo:checkProcess.getCheckInformationMap().values()) {
					if (!checkInfo.getResultType().equals(CheckResultType.PASSED))
							return false;
				}
			}
			return true;
		}
		
	}

	public class CheckViewResultTypeFilter extends ViewerFilter {

		private boolean showNonErrors = true;

		private CheckResultType[] non_errors = { CheckResultType.NOT_CHECKED,
				CheckResultType.INFO, CheckResultType.PASSED,
				CheckResultType.WARNING };

		public CheckViewResultTypeFilter() {
			super();
		}

		public boolean isShowNonErrors() {
			return showNonErrors;
		}

		public void switchShowNonErrors() {
			showNonErrors = !showNonErrors;
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
			if (element instanceof DefaultOkObject)
				return true;
			if (element instanceof CheckProcess<?, ?>) {
				CheckProcess<?, ?> cp = (CheckProcess<?, ?>) element;
				return display(getResultType(cp));
			}
			if (element instanceof CheckResult<?, ?>) {
				CheckResult<E, A> result = (CheckResult<E, A>) element;
				return display(result.getType());
			}
			if (element instanceof CheckModule<?, ?>) {
				CheckModule<E, A> module = (CheckModule<E, A>) element;
				return display(getResultType(module.getClass()));
			}
			if (element instanceof _CincoId) {
				_CincoId id = (_CincoId) element;
				return display(getCheckProcessById(id).getCheckInformationMap()
						.get(id).getResultType());
			}
			return false;
		}

		private boolean display(CheckResultType type) {
			if (showNonErrors)
				return true;
			if (Arrays.asList(non_errors).contains(type))
				return false;
			return true;
		}

	}

}
