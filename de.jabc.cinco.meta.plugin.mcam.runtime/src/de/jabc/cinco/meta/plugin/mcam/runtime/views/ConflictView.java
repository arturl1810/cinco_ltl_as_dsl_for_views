package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import java.io.File;

import info.scce.mcam.framework.processes.MergeInformation.MergeType;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.ConflictViewTreeProvider.ViewType;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

@SuppressWarnings("rawtypes")
public class ConflictView extends McamView<ConflictViewPage> {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "de.jabc.cinco.meta.plugin.mcam.runtime.views.ConflictView";

	private IAction showByIdViewAction;
	
	private IAction sortByMergeTypeAction;
	private IAction sortByNameAction;
	
	/*
	 * Filtering
	 */
	private IAction filterNothingAction;
	
	private IAction filterOnlyConflictedAction;
	private IAction filterOnlyAddedAction;
	private IAction filterOnlyChangedAction;
	private IAction filterOnlyDeletedAction;

	@Override
	protected void fillLocalPullDown(IMenuManager manager) {
		IMenuManager viewSubmenu = new MenuManager("Views");
		manager.add(viewSubmenu);
		viewSubmenu.add(showByIdViewAction);

		IMenuManager filterSubmenu = new MenuManager("Filters");
		manager.add(filterSubmenu);
		filterSubmenu.add(filterNothingAction);
		filterSubmenu.add(filterOnlyAddedAction);
		filterSubmenu.add(filterOnlyChangedAction);
		filterSubmenu.add(filterOnlyConflictedAction);
		filterSubmenu.add(filterOnlyDeletedAction);
		
		IMenuManager sortSubmenu = new MenuManager("Sort By");
		manager.add(sortSubmenu);
		sortSubmenu.add(sortByNameAction);
		sortSubmenu.add(sortByMergeTypeAction);
		
		//manager.add(new Separator());
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
//		manager.add(reloadAction);
		manager.add(expandAllAction);
		manager.add(collapseAllAction);
		manager.add(new Separator());
	}

	@Override
	protected void makeActions() {
		super.makeActions();
		
		/*
		 * ------------------------------------------ */
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
		saveAction = new Action() {
			public void run() {
				if (activeConflictViewInformation != null) {

					//activeConflictViewInformation.getMp().getMergeModelAdapter().writeModel(activeConflictViewInformation.getOrigFile());

					activeConflictViewInformation.getLocalFile().delete();
					activeConflictViewInformation.getRemoteFile().delete();

					activeConflictViewInformation.closeView();
					try {
						activeConflictViewInformation.getIFile().getProject().refreshLocal(IResource.DEPTH_INFINITE, monitor);
					} catch (CoreException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					conflictInfoMap.remove(activeConflictViewInformation.getOrigFile());

					activeConflictViewInformation = null;
					saveAction.setEnabled(false);
					
					if (!parent.isDisposed()) {
						parent.layout(true);
						parent.redraw();
						parent.update();
					}

					MessageDialog
							.openInformation(parent.getShell(),
									"Conflict View",
									"Conflict resolution saved. Temporary files removed");
				}
			}
		};
		saveAction.setText("save");
		saveAction.setToolTipText("save conflict resolution");
		saveAction.setImageDescriptor(PlatformUI.getWorkbench()
				.getSharedImages()
				.getImageDescriptor(ISharedImages.IMG_ETOOL_SAVE_EDIT));
		saveAction.setEnabled(false);
		*/

		/*
		 * ------------------------------------------ */
		sortByMergeTypeAction = new Action() {
			public void run() {
				updateSorter(sortByMergeTypeAction);
			}
		};
		sortByMergeTypeAction.setText("sort by merge type");
		sortByMergeTypeAction.setToolTipText("sort ids by merge type");
		sortByMergeTypeAction.setEnabled(true);
		sortByMergeTypeAction.setChecked(false);
		
		sortByNameAction = new Action() {
			public void run() {
				updateSorter(sortByNameAction);
			}
		};
		sortByNameAction.setText("sort by name");
		sortByNameAction.setToolTipText("sort ids by name alphabetical");
		sortByNameAction.setEnabled(true);
		sortByNameAction.setChecked(false);
		
		

		/*
		 * ------------------------------------------ */
		filterNothingAction = new Action() {
			public void run() {
				updateFilter(filterNothingAction);
			}
		};
		filterNothingAction.setText("show all");
		filterNothingAction.setToolTipText("show all ids");
		filterNothingAction.setEnabled(true);
		filterNothingAction.setChecked(false);
		
		filterOnlyAddedAction = new Action() {
			public void run() {
				updateFilter(filterOnlyAddedAction);
			}
		};
		filterOnlyAddedAction.setText("show added");
		filterOnlyAddedAction.setToolTipText("show added ids");
		filterOnlyAddedAction.setEnabled(true);
		filterOnlyAddedAction.setChecked(false);
		
		filterOnlyChangedAction = new Action() {
			public void run() {
				updateFilter(filterOnlyChangedAction);
			}
		};
		filterOnlyChangedAction.setText("show changed");
		filterOnlyChangedAction.setToolTipText("show changed ids");
		filterOnlyChangedAction.setEnabled(true);
		filterOnlyChangedAction.setChecked(false);
		
		filterOnlyConflictedAction = new Action() {
			public void run() {
				updateFilter(filterOnlyConflictedAction);
			}
		};
		filterOnlyConflictedAction.setText("show conflicted");
		filterOnlyConflictedAction.setToolTipText("show conflicted ids");
		filterOnlyConflictedAction.setEnabled(true);
		filterOnlyConflictedAction.setChecked(false);
		
		filterOnlyDeletedAction = new Action() {
			public void run() {
				updateFilter(filterOnlyDeletedAction);
			}
		};
		filterOnlyDeletedAction.setText("show deleted");
		filterOnlyDeletedAction.setToolTipText("show deleted ids");
		filterOnlyDeletedAction.setEnabled(true);
		filterOnlyDeletedAction.setChecked(false);
		
	}

	@Override
	protected void reloadViewState() {
		showByIdViewAction.setChecked(false);

		switch (activePage.getDataProvider().getActiveView()) {
		case BY_ID:
			showByIdViewAction.setChecked(true);
			break;

		default:
			break;
		}
		
		restoreActiveFilter(activePage.getActiveFilter());
		restoreActiveSorter(activePage.getActiveSort());

		activePage.getTreeViewer().refresh();
	}

	protected void updateSorter(IAction action) {
		sortByNameAction.setChecked(false);
		sortByMergeTypeAction.setChecked(false);
		if(action == sortByNameAction) {
			sortByNameAction.setChecked(true);
			activePage.setActiveSort(1);
			activePage.getTreeViewer().setSorter(activePage.getNameSorter());
		}
		if(action == sortByMergeTypeAction) {
			sortByMergeTypeAction.setChecked(true);
			activePage.setActiveSort(0);
			activePage.getTreeViewer().setSorter(activePage.getTypeSorter());
		}
	}
	
	private void restoreActiveSorter(int sorter) {
		switch (sorter) {
			case 1:
				sortByNameAction.run();
				break;
			case 0:
			default:
				sortByMergeTypeAction.run();
				break;
		}
	}
	

	protected void updateFilter(IAction action) {
		filterNothingAction.setChecked(false);
		
		filterOnlyAddedAction.setChecked(false);
		activePage.getTreeViewer().removeFilter(activePage.getConflictViewTypeFilter(MergeType.ADDED));
		
		filterOnlyChangedAction.setChecked(false);
		activePage.getTreeViewer().removeFilter(activePage.getConflictViewTypeFilter(MergeType.CHANGED));
		
		filterOnlyDeletedAction.setChecked(false);
		activePage.getTreeViewer().removeFilter(activePage.getConflictViewTypeFilter(MergeType.DELETED));
		
		filterOnlyConflictedAction.setChecked(false);
		activePage.getTreeViewer().removeFilter(activePage.getConflictViewTypeFilter(MergeType.CONFLICTED));
		
		if(action == filterNothingAction) {
			filterNothingAction.setChecked(true);
			activePage.setActiveFilter(0);
		}
		
		if(action == filterOnlyAddedAction) {
			activePage.getTreeViewer().addFilter(activePage.getConflictViewTypeFilter(MergeType.ADDED));
			filterOnlyAddedAction.setChecked(true);
			activePage.setActiveFilter(1);
		}
		if(action == filterOnlyChangedAction) {
			activePage.getTreeViewer().addFilter(activePage.getConflictViewTypeFilter(MergeType.CHANGED));
			filterOnlyChangedAction.setChecked(true);
			activePage.setActiveFilter(2);
		}
		if(action == filterOnlyDeletedAction) {
			activePage.getTreeViewer().addFilter(activePage.getConflictViewTypeFilter(MergeType.DELETED));
			filterOnlyDeletedAction.setChecked(true);
			activePage.setActiveFilter(3);
		}
		if(action == filterOnlyConflictedAction) {
			activePage.getTreeViewer().addFilter(activePage.getConflictViewTypeFilter(MergeType.CONFLICTED));
			filterOnlyConflictedAction.setChecked(true);
			activePage.setActiveFilter(4);
		}
	}

	private void restoreActiveFilter(int filter) {
		switch (filter) {
			case 1:
				filterOnlyAddedAction.run();
				break;
			case 2:
				filterOnlyChangedAction.run();
				break;
			case 3:
				filterOnlyDeletedAction.run();
				break;
			case 4:
				filterOnlyConflictedAction.run();
				break;
			case 0:
			default:
				filterNothingAction.run();
				break;
		}
	}

	@Override
	public ConflictViewPage<?, ?, ?> createPage(String pageId, IEditorPart editor) {
		PageFactory pf = getPageFactory();
		if (pf != null)
			return pf.createConflictViewPage(pageId, editor);
		return null;
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

	@Override
	protected void initView(Composite parent) {
		// TODO Auto-generated method stub
		
	}

}
