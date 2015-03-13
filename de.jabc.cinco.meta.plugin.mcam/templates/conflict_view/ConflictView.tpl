package ${ConflictViewPackage}.views;

import info.scce.cinco.product.flowgraph.mcam.cli.FrameworkExecution;

import java.io.File;
import java.util.HashMap;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.*;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.jface.action.*;
import org.eclipse.jface.dialogs.MessageDialog;
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
	public static final String ID = "info.scce.cinco.product.flowgraph.mcam.conflictview.views.ConflictView";

	private Action saveAction;
	
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
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.addPartListener(this);
		System.out.println("View created");

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
		// manager.add(new Separator());
	}

	private void fillLocalToolBar(IToolBarManager manager) {
		manager.add(saveAction);
	}

	private void makeActions() {
		saveAction = new Action() {
			public void run() {
				if (activeConflictViewInformation != null) {

					activeConflictViewInformation.getMp().getMergeModelAdapter().writeModel(activeConflictViewInformation.getOrigFile());

					activeConflictViewInformation.getLocalFile().delete();
					activeConflictViewInformation.getRemoteFile().delete();

					activeConflictViewInformation.getTree().dispose();
					try {
						activeConflictViewInformation.getIFile().getProject().refreshLocal(IResource.DEPTH_INFINITE, monitor);
					} catch (CoreException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					conflictInfoMap.remove(activeConflictViewInformation.getOrigFile());

					activeConflictViewInformation = null;
					saveAction.setEnabled(false);
					
					parent.redraw();
					parent.layout();
					parent.update();

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
		System.out.println("Part active: " + partRef.getTitle());
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
		System.out.println("Part to top: " + partRef.getTitle());
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
		System.out.println("Part closed: " + partRef.getTitle());

		if (partRef instanceof EditorReference) {
			IFile file = (IFile) ((EditorReference) partRef).getEditor(false)
					.getEditorInput().getAdapter(IFile.class);

			if (file != null) {
				String path = file.getRawLocation().toOSString();
				File origFile = FrameworkExecution.getFile(path);

				System.out.println("Closed File: " + origFile.getName());

				if (conflictInfoMap.keySet().contains(origFile)) {
					ConflictViewInformation activeConflictView = conflictInfoMap
							.get(origFile);
					activeConflictView.getTree().dispose();
					conflictInfoMap.remove(origFile);

					activeConflictViewInformation = null;
					saveAction.setEnabled(false);
				}
			}
		}

		parent.redraw();
		parent.layout();
		parent.update();
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
		System.out.println("Part deactivated: " + partRef.getTitle());
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
		System.out.println("Part opened: " + partRef.getTitle());
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
		System.out.println("Part hidden: " + partRef.getTitle());
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
		System.out.println("Part visible: " + partRef.getTitle());

		if (partRef instanceof EditorReference) {
			IFile file = (IFile) ((EditorReference) partRef).getEditor(false)
					.getEditorInput().getAdapter(IFile.class);

			for (Control child : parent.getChildren()) {
				child.setVisible(false);
			}

			if (file != null) {
				String path = file.getRawLocation().toOSString();
				
				File origFile = FrameworkExecution.getFile(path);
				File remoteFile = FrameworkExecution.getFile(path + ".remote");
				File localFile = FrameworkExecution.getFile(path + ".local");
				if (origFile.exists() && localFile.exists()
						&& remoteFile.exists()) {

					if (!conflictInfoMap.keySet().contains(origFile)) {
						ConflictViewInformation conflictInfo = new ConflictViewInformation(
								origFile, remoteFile, localFile, file);
						conflictInfo.createMergeCheckProcess();
						conflictInfo.createConflictViewTree(parent);
						conflictInfoMap.put(origFile, conflictInfo);
					}

					activeConflictViewInformation = conflictInfoMap
							.get(origFile);
					activeConflictViewInformation.getTree().setVisible(true);
					saveAction.setEnabled(true);
				} else {
					saveAction.setEnabled(false);
				}
			}
		}

		parent.redraw();
		parent.layout();
		parent.update();
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		System.out.println("Part input changed: " + partRef.getTitle());
	}
}
