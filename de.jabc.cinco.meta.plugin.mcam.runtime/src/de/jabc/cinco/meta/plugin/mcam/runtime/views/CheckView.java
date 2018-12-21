package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import java.io.File;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.CheckViewTreeProvider.ViewType;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.ResourceChangeListener;

@SuppressWarnings("rawtypes")
public class CheckView extends McamView<CheckViewPage> {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "de.jabc.cinco.meta.plugin.mcam.runtime.views.CheckView";

	protected ResourceChangeListener resourceChangeListener;

	private IAction showByModuleViewAction;
	private IAction showByIdViewAction;

	private IAction showNonErrorsAction;
	private IAction showCheckPerformanceAction;
	private IAction stopAtFirstErrorAction;

	@Override
	protected void initView(Composite parent) {
		resourceChangeListener = new ResourceChangeListener(this);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(
				resourceChangeListener);

	}

	@Override
	protected void fillLocalPullDown(IMenuManager manager) {
		IMenuManager filterSubmenu = new MenuManager("Filters");
		filterSubmenu.add(showNonErrorsAction);

		IMenuManager viewSubmenu = new MenuManager("Views");
		viewSubmenu.add(showByModuleViewAction);
		viewSubmenu.add(showByIdViewAction);

		manager.add(filterSubmenu);
		manager.add(viewSubmenu);
		
		manager.add(showCheckPerformanceAction);
		manager.add(stopAtFirstErrorAction);

		// manager.add(new Separator());
	}

	@Override
	protected void fillContextMenu(IMenuManager manager) {
		manager.add(openModelAction);
		// manager.add(new Separator());
		// // Other plug-ins can contribute there actions here
		// manager.add(new Separator(IWorkbenchActionConstants.MB_ADDITIONS));
	}

	@Override
	protected void fillLocalToolBar(IToolBarManager manager) {
		manager.add(reloadAction);
		manager.add(expandAllAction);
		manager.add(collapseAllAction);
		manager.add(new Separator());
	}

	@Override
	protected void makeActions() {
		super.makeActions();

		/*
		 * ------------------------------------------
		 */
		showByIdViewAction = new Action() {
			public void run() {
				activePage.getDataProvider().setActiveView(ViewType.BY_ID);

//				activePage.getTreeViewer().refresh(true);
				activePage.getTreeViewer().setInput(getViewSite());
				reloadViewState();
			}
		};
		showByIdViewAction.setText("by entity");
		showByIdViewAction.setToolTipText("show results by entity");
		showByIdViewAction.setChecked(false);

		/*
		 * ------------------------------------------
		 */
		showByModuleViewAction = new Action() {
			public void run() {
				activePage.getDataProvider().setActiveView(ViewType.BY_MODULE);

//				activePage.getTreeViewer().refresh(true);
				activePage.getTreeViewer().setInput(getViewSite());
				reloadViewState();
			}
		};
		showByModuleViewAction.setText("by module");
		showByModuleViewAction.setToolTipText("show results by module");
		showByModuleViewAction.setChecked(false);

		/*
		 * ------------------------------------------
		 */
		showNonErrorsAction = new Action() {
			public void run() {
				activePage.getTreeViewer().removeFilter(
						activePage.getResultTypeFilter());
				activePage.getResultTypeFilter().switchShowNonErrors();
				activePage.getTreeViewer().addFilter(
						activePage.getResultTypeFilter());

//				activePage.getTreeViewer().refresh(true);
				activePage.getTreeViewer().setInput(getViewSite());
				reloadViewState();
			}
		};
		showNonErrorsAction.setText("show non-errors");
		showNonErrorsAction
				.setToolTipText("show warnings and less important entries");
		showNonErrorsAction.setChecked(true);
		
		/*
		 * ------------------------------------------
		 */
		showCheckPerformanceAction = new Action() {
			public void run() {
				
				activePage.getLabelProvider().setShowPerformance(!activePage.getLabelProvider().isShowPerformance());
				
				activePage.getTreeViewer().refresh(true);
//				activePage.getTreeViewer().setInput(getViewSite());
				reloadViewState();
			}
		};
		showCheckPerformanceAction.setText("show check perfomance");
		showCheckPerformanceAction
				.setToolTipText("show check perfomance");
		showCheckPerformanceAction.setChecked(false);
		
		/*
		 * ------------------------------------------
		 */
		stopAtFirstErrorAction = new Action() {
			public void run() {
				activePage.getCheckConfiguration().switchStopAtFirstError();
				activePage.getTreeViewer().refresh(true);
				reloadViewState();
			}
		};
		stopAtFirstErrorAction.setText("stop at first error");
		stopAtFirstErrorAction
				.setToolTipText("stop at first error");
		stopAtFirstErrorAction.setChecked(false);

	}

	@Override
	protected void reloadViewState() {
		showByIdViewAction.setChecked(false);
		showByModuleViewAction.setChecked(false);

		showNonErrorsAction.setChecked(activePage.getResultTypeFilter()
				.isShowNonErrors());
		
		showCheckPerformanceAction.setChecked(activePage.getLabelProvider().isShowPerformance());
		
		stopAtFirstErrorAction.setChecked(activePage.getCheckConfiguration().isStopAtFirstError());

		switch (activePage.getDataProvider().getActiveView()) {
		case BY_ID:
			showByIdViewAction.setChecked(true);
			break;

		case BY_MODULE:
			showByModuleViewAction.setChecked(true);
			break;

		default:
			break;
		}
		// activePage.getTreeViewer().refresh();
	}

	@Override
	public CheckViewPage<?, ?, ?> createPage(String id, IEditorPart editor) {
		List<PageFactory> pfs = getPageFactories();
		for (PageFactory pf : pfs) {
			CheckViewPage<?, ?, ?> page = pf.createCheckViewPage(id, editor);
			if (page != null)
				return page;
		}
		return null;
	}

	@Override
	public void dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(
				resourceChangeListener);
		super.dispose();
	}

	@Override
	public String getPageId(IResource res) {
		if (res instanceof IFile == false || res == null)
			return null;

		IFile file = (IFile) res;
		String path = file.getRawLocation().toOSString();
		File origFile = new File(path);
		return origFile.getAbsolutePath();
	}

}
