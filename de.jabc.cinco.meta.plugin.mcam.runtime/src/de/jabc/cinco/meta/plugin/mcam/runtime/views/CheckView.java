package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.swt.widgets.Composite;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.CheckViewTreeProvider.ViewType;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;
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

	public CheckView() {
		this.genericParameterClass = CheckViewPage.class;
	}

	@Override
	protected void initView(Composite parent) {
		super.initView(parent);

		resourceChangeListener = new ResourceChangeListener(this);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(
				resourceChangeListener);

	}

	@Override
	protected void fillLocalPullDown(IMenuManager manager) {
		IMenuManager filterSubmenu = new MenuManager("Filters");

		IMenuManager viewSubmenu = new MenuManager("Views");
		viewSubmenu.add(showByModuleViewAction);
		viewSubmenu.add(showByIdViewAction);

		manager.add(filterSubmenu);
		manager.add(viewSubmenu);

		// manager.add(new Separator());
	}

	@Override
	protected void fillContextMenu(IMenuManager manager) {
		// manager.add(openModelAction);
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
				activePage.getTreeViewer().setLabelProvider(
						activePage.getDefaultLabelProvider());

				EclipseUtils.runBusy(new Runnable() {
					public void run() {
						activePage.reload();
						reloadViewState();
					}
				});
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
				activePage.getTreeViewer().setLabelProvider(
						activePage.getDefaultLabelProvider());

				EclipseUtils.runBusy(new Runnable() {
					public void run() {
						activePage.reload();
						reloadViewState();
					}
				});
			}
		};
		showByModuleViewAction.setText("by module");
		showByModuleViewAction.setToolTipText("show results by module");
		showByModuleViewAction.setChecked(false);

	}

	@Override
	protected void reloadViewState() {
		showByIdViewAction.setChecked(false);
		showByModuleViewAction.setChecked(false);

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

		activePage.getTreeViewer().refresh();
	}

	@Override
	public CheckViewPage<?, ?, ?> createPage(IFile file) {
		PageFactory pf = getPageFactory();
		if (pf != null)
			return pf.createCheckViewPage(file);
		return null;
	}

	@Override
	public void dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(
				resourceChangeListener);
		super.dispose();
	}

}
