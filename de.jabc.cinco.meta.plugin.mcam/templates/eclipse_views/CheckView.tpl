package ${ViewPackage}.views;

import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;

import java.io.File;
import java.util.HashMap;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.ViewPart;

public class CheckView extends ViewPart implements IPartListener2 {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "info.scce.cinco.product.flowgraph.mcam.views.views.CheckView";

	private NullProgressMonitor monitor = new NullProgressMonitor();

	private Composite parent = null;

	private CheckViewInformation activeCheckViewInformation = null;

	private HashMap<File, CheckViewInformation> checkInfoMap = new HashMap<>();

	/**
	 * The constructor.
	 */
	public CheckView() {
	}

	/**
	 * This is a callback that will allow us to create the viewer and initialize
	 * it.
	 */

	public void createPartControl(Composite parent) {

		this.parent = parent;
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
		// manager.add(saveAction);
		// manager.add(new Separator());
	}

	private void fillLocalToolBar(IToolBarManager manager) {
		// manager.add(saveAction);
	}

	private void makeActions() {
//		saveAction = new Action() {
//			public void run() {
//				if (activeCheckViewInformation != null) {
//
//					//activeConflictViewInformation.getMp().getMergeModelAdapter().writeModel(activeConflictViewInformation.getOrigFile());
//
//					activeCheckViewInformation.getLocalFile().delete();
//					activeCheckViewInformation.getRemoteFile().delete();
//
//					activeCheckViewInformation.getTree().dispose();
//					try {
//						activeCheckViewInformation.getIFile().getProject().refreshLocal(IResource.DEPTH_INFINITE, monitor);
//					} catch (CoreException e) {
//						// TODO Auto-generated catch block
//						e.printStackTrace();
//					}
//					conflictInfoMap.remove(activeCheckViewInformation.getOrigFile());
//
//					activeCheckViewInformation = null;
//					saveAction.setEnabled(false);
//					
//					parent.redraw();
//					parent.layout();
//					parent.update();
//
//					MessageDialog
//							.openInformation(parent.getShell(),
//									"Conflict View",
//									"Conflict resolution saved. Temporary files removed");
//				}
//			}
//		};
//		saveAction.setText("save");
//		saveAction.setToolTipText("save conflict resolution");
//		saveAction.setImageDescriptor(PlatformUI.getWorkbench()
//				.getSharedImages()
//				.getImageDescriptor(ISharedImages.IMG_ETOOL_SAVE_EDIT));
//		saveAction.setEnabled(false);

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

				if (checkInfoMap.keySet().contains(origFile)) {
					CheckViewInformation activeCheckViewInformation = checkInfoMap
							.get(origFile);
					activeCheckViewInformation.getTree().dispose();
					checkInfoMap.remove(origFile);

					activeCheckViewInformation = null;
//					saveAction.setEnabled(false);
				}
			}
		}

		parent.redraw();
		parent.layout();
		parent.update();
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

			for (Control child : parent.getChildren()) {
				child.setVisible(false);
			}

			if (file != null && res != null) {
				String path = file.getRawLocation().toOSString();
				
				File origFile = FrameworkExecution.getFile(path);
				if (origFile.exists()) {

					if (!checkInfoMap.keySet().contains(origFile)) {
						CheckViewInformation checkInfo = new CheckViewInformation(
								origFile, res);
						checkInfo.createCheckProcess();
						checkInfo.createCheckViewTree(parent);
						checkInfoMap.put(origFile, checkInfo);
					}

					activeCheckViewInformation = checkInfoMap
							.get(origFile);
					activeCheckViewInformation.getTree().setVisible(true);
//					saveAction.setEnabled(true);
				} else {
//					saveAction.setEnabled(false);
				}
			}
		}

		parent.redraw();
		parent.layout();
		parent.update();
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		// System.out.println("Part input changed: " + partRef.getTitle());
	}

}

