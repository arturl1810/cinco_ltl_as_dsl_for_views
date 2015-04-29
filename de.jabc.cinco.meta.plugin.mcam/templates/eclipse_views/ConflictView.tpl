package ${ViewPackage}.views;

import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;
import ${ViewPackage}.util.MergeProcessTypeFilter;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;

import java.io.File;
import java.util.HashMap;

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.*;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.*;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.ui.*;

/**
 * This sample class demonstrates how to plug-in a new workbench view. The view
 * shows data obtained from the model. The sample creates a dummy model on the
 * fly, but a real implementation would connect to the model available either in
 * this or another plug-in (e.g. the workspace). The view is connected to the
 * model using a content provider.
 * <p>
 * The view uses a label provider to define how model objects should be
 * presented in the view. Each view can present the same model objects using
 * different labels and icons, if needed. Alternatively, a single label provider
 * can be shared between views in order to ensure that objects of the same type
 * are presented in the same way everywhere.
 * <p>
 */

@SuppressWarnings("restriction")
public class ConflictView extends ViewPart implements IPartListener2 {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "${ViewPackage}.views.ConflictView";

	private Action saveAction;

	private Action sortByStateAction;
	
	/*
	 * Filtering
	 */
	private Action filterNothing;
	
	private Action filterOnlyConflicted;
	private ViewerFilter onlyConflictedFilter = new MergeProcessTypeFilter(MergeType.CONFLICTED);
	
	private Action filterOnlyAdded;
	private ViewerFilter onlyAddedFilter = new MergeProcessTypeFilter(MergeType.ADDED);
	
	private Action filterOnlyChanged;
	private ViewerFilter onlyChangedFilter = new MergeProcessTypeFilter(MergeType.CHANGED);
	
	private Action filterOnlyDeleted;
	private ViewerFilter onlyDeletedFilter = new MergeProcessTypeFilter(MergeType.DELETED);
	
	
	private NullProgressMonitor monitor = new NullProgressMonitor();

	private Composite parent = null;

	private ConflictViewInformation activeConflictViewInformation = null;

	private HashMap<File, ConflictViewInformation> conflictInfoMap = new HashMap<>();

	/**
	 * The constructor.
	 */
	public ConflictView() {
	}

	/**
	 * This is a callback that will allow us to create the viewer and initialize
	 * it.
	 */

	public void createPartControl(Composite parent) {

		this.parent = parent;
		this.parent.setLayout(new GridLayout(1, true));
		this.parent.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.addPartListener(this);
		// System.out.println("View created");

		// hookContextMenu();
		// hookDoubleClickAction();
		
		makeActions();
		contributeToActionBars();
	}

	/*
	private void hookContextMenu() {
		MenuManager menuMgr = new MenuManager("#PopupMenu");
		menuMgr.setRemoveAllWhenShown(true);
		menuMgr.addMenuListener(new IMenuListener() {
			public void menuAboutToShow(IMenuManager manager) {
				ConflictView.this.fillContextMenu(manager);
			}
		});
		Menu menu = menuMgr.createContextMenu(viewer.getControl());
		viewer.getControl().setMenu(menu);
		getSite().registerContextMenu(menuMgr, viewer);
	}
	
	private void fillContextMenu(IMenuManager manager) {
		manager.add(saveAction);
		// Other plug-ins can contribute there actions here
		// manager.add(new Separator(IWorkbenchActionConstants.MB_ADDITIONS));
	}
	*/

	private void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	private void fillLocalPullDown(IMenuManager manager) {
		manager.add(saveAction);
		manager.add(new Separator());
		IMenuManager filterSubmenu = new MenuManager("Filters");
		manager.add(filterSubmenu);
		filterSubmenu.add(filterNothing);
		filterSubmenu.add(filterOnlyAdded);
		filterSubmenu.add(filterOnlyChanged);
		filterSubmenu.add(filterOnlyConflicted);
		filterSubmenu.add(filterOnlyDeleted);
		
		IMenuManager sortSubmenu = new MenuManager("Sort By");
		manager.add(sortSubmenu);
		sortSubmenu.add(sortByStateAction);
	}

	private void fillLocalToolBar(IToolBarManager manager) {
		manager.add(saveAction);
	}

	private void makeActions() {
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

		sortByStateAction = new Action() {
			public void run() {
				if (activeConflictViewInformation != null) {
					if (!parent.isDisposed()) {
						parent.layout(true);
						parent.redraw();
						parent.update();
					}
				}
			}
		};
		sortByStateAction.setText("sortBy state");
		sortByStateAction.setToolTipText("sort Ids by state");
		sortByStateAction.setEnabled(true);

		filterNothing = new Action() {
			public void run() {
				updateFilter(filterNothing);
			}
		};
		filterNothing.setText("show all");
		filterNothing.setToolTipText("show all ids");
		filterNothing.setEnabled(true);
		filterNothing.setChecked(true);
		
		filterOnlyAdded = new Action() {
			public void run() {
				updateFilter(filterOnlyAdded);
			}
		};
		filterOnlyAdded.setText("show added");
		filterOnlyAdded.setToolTipText("show added ids");
		filterOnlyAdded.setEnabled(true);
		filterOnlyAdded.setChecked(false);
		
		filterOnlyChanged = new Action() {
			public void run() {
				updateFilter(filterOnlyChanged);
			}
		};
		filterOnlyChanged.setText("show changed");
		filterOnlyChanged.setToolTipText("show changed ids");
		filterOnlyChanged.setEnabled(true);
		filterOnlyChanged.setChecked(false);
		
		filterOnlyConflicted = new Action() {
			public void run() {
				updateFilter(filterOnlyConflicted);
			}
		};
		filterOnlyConflicted.setText("show conflicted");
		filterOnlyConflicted.setToolTipText("show conflicted ids");
		filterOnlyConflicted.setEnabled(true);
		filterOnlyConflicted.setChecked(false);
		
		filterOnlyDeleted = new Action() {
			public void run() {
				updateFilter(filterOnlyDeleted);
			}
		};
		filterOnlyDeleted.setText("show deleted");
		filterOnlyDeleted.setToolTipText("show deleted ids");
		filterOnlyDeleted.setEnabled(true);
		filterOnlyDeleted.setChecked(false);
		

	}
	
	/* Multiple filters can be enabled at a time. */
	protected void updateFilter(Action action) {
		filterNothing.setChecked(false);
		
		filterOnlyAdded.setChecked(false);
		activeConflictViewInformation.getTreeViewer().removeFilter(onlyAddedFilter);
		
		filterOnlyChanged.setChecked(false);
		activeConflictViewInformation.getTreeViewer().removeFilter(onlyChangedFilter);
		
		filterOnlyDeleted.setChecked(false);
		activeConflictViewInformation.getTreeViewer().removeFilter(onlyDeletedFilter);
		
		filterOnlyConflicted.setChecked(false);
		activeConflictViewInformation.getTreeViewer().removeFilter(onlyConflictedFilter);
		
		if(action == filterNothing) {
			filterNothing.setChecked(true);
			activeConflictViewInformation.setActiveFilter(0);
		}
		
		if(action == filterOnlyAdded) {
				activeConflictViewInformation.getTreeViewer().addFilter(onlyAddedFilter);
				filterOnlyAdded.setChecked(true);
				activeConflictViewInformation.setActiveFilter(1);
		}
		if(action == filterOnlyChanged) {
				activeConflictViewInformation.getTreeViewer().addFilter(onlyChangedFilter);
				filterOnlyChanged.setChecked(true);
				activeConflictViewInformation.setActiveFilter(2);
		}
		if(action == filterOnlyDeleted) {
				activeConflictViewInformation.getTreeViewer().addFilter(onlyDeletedFilter);
				filterOnlyDeleted.setChecked(true);
				activeConflictViewInformation.setActiveFilter(3);
		}
		if(action == filterOnlyConflicted) {
				activeConflictViewInformation.getTreeViewer().addFilter(onlyConflictedFilter);
				filterOnlyConflicted.setChecked(true);
				activeConflictViewInformation.setActiveFilter(4);
		}
	}

	private void restoreActiveFilter(int filter) {
		switch (filter) {
			case 1:
				updateFilter(filterOnlyAdded);
				break;
			case 2:
				updateFilter(filterOnlyChanged);
				break;
			case 3:
				updateFilter(filterOnlyDeleted);
				break;
			case 4:
				updateFilter(filterOnlyConflicted);
				break;
			case 0:
			default:
				updateFilter(filterNothing);
				break;
		}
	}

	/**
	 * Passing the focus request to the viewer's control.
	 */
	public void setFocus() {
		// viewer.getControl().setFocus();
	}

	/**
	 * Part Listener Methods
	 */
	@Override
	public void partActivated(IWorkbenchPartReference partRef) {
		// System.out.println("Part active: " + partRef.getTitle());
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
		// System.out.println("Part to top: " + partRef.getTitle());
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
		// System.out.println("Part closed: " + partRef.getTitle());

		if (partRef instanceof EditorReference) {
			IFile file = (IFile) ((EditorReference) partRef).getEditor(false)
					.getEditorInput().getAdapter(IFile.class);

			if (file != null) {
				String path = file.getRawLocation().toOSString();
				File origFile = FrameworkExecution.getFile(path);

				// System.out.println("Closed File: " + origFile.getName());

				if (conflictInfoMap.keySet().contains(origFile)) {
					ConflictViewInformation activeConflictView = conflictInfoMap
							.get(origFile);
					activeConflictView.closeView();
					conflictInfoMap.remove(origFile);

					activeConflictViewInformation = null;
					saveAction.setEnabled(false);

					if (!parent.isDisposed()) {
						parent.layout(true);
						parent.redraw();
						parent.update();
					}
				}
			}
		}
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
		// System.out.println("Part deactivated: " + partRef.getTitle());
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
		// System.out.println("Part opened: " + partRef.getTitle());
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
		// System.out.println("Part hidden: " + partRef.getTitle());
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
		// System.out.println("Part visible: " + partRef.getTitle());

		if (partRef instanceof EditorReference) {
			IFile file = (IFile) ((EditorReference) partRef).getEditor(false)
					.getEditorInput().getAdapter(IFile.class);

			Resource res = null;
			IEditorPart editor = ((EditorReference) partRef).getEditor(false);
			if (editor instanceof DiagramEditor) {
				DiagramEditor deditor = (DiagramEditor) editor;
				TransactionalEditingDomain ed = deditor.getEditingDomain();	
				ResourceSet rs = ed.getResourceSet();
				res = rs.getResources().get(0);
			}

			if (parent.isDisposed())
				return;

			for (Control child : parent.getChildren()) {
				child.setVisible(false);
				((GridData) child.getLayoutData()).exclude = true;
			}

			if (file != null && res != null) {
				String path = file.getRawLocation().toOSString();
				
				File origFile = FrameworkExecution.getFile(path);
				File remoteFile = FrameworkExecution.getFile(path + ".remote");
				File localFile = FrameworkExecution.getFile(path + ".local");
				if (origFile.exists() && localFile.exists()
						&& remoteFile.exists()) {

					if (!conflictInfoMap.keySet().contains(origFile)) {
						ConflictViewInformation conflictInfo = new ConflictViewInformation(
								origFile, remoteFile, localFile, file, res);
						conflictInfo.createMergeProcess();
						conflictInfo.runInitialChangeExecution();
						conflictInfo.createConflictViewTree(parent);
						conflictInfoMap.put(origFile, conflictInfo);
					}

					activeConflictViewInformation = conflictInfoMap
							.get(origFile);
					activeConflictViewInformation.getTreeViewer().getTree().setVisible(true);
					restoreActiveFilter(activeConflictViewInformation.getActiveFilter());
					((GridData) activeConflictViewInformation.getTreeViewer().getTree().getLayoutData()).exclude = false;
					parent.layout();
					saveAction.setEnabled(true);
				} else {
					saveAction.setEnabled(false);
				}
			}
		}

		if (!parent.isDisposed()) {
			parent.layout(true);
			parent.redraw();
			parent.update();
		}
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		// System.out.println("Part input changed: " + partRef.getTitle());
	}
}
