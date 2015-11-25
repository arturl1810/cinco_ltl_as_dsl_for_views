package ${McamViewBasePackage};

import java.io.File;
import java.util.HashMap;

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.ViewPart;

@SuppressWarnings("restriction")
public class CheckView extends ViewPart implements IPartListener2 {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "${McamViewBasePackage}.CheckView";

	private Composite parent = null;

	private Action reloadAction;

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
		this.parent.setLayout(new GridLayout(1, true));
		this.parent.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.addPartListener(this);

		makeActions();
		contributeToActionBars();
	}

	private void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	private void fillLocalPullDown(IMenuManager manager) {
		manager.add(reloadAction);
		// manager.add(new Separator());
	}

	private void fillLocalToolBar(IToolBarManager manager) {
		manager.add(reloadAction);
	}

	private void makeActions() {
		reloadAction = new Action() {
			public void run() {
				if (activeCheckViewInformation != null) {
					activeCheckViewInformation.closeView();
					activeCheckViewInformation.createCheckProcess();
					activeCheckViewInformation.createCheckViewTree(parent);

					if (!parent.isDisposed()) {
						parent.layout(true);
						parent.redraw();
						parent.update();
					}

//					MessageDialog.openInformation(parent.getShell(),
//							"Check View", "Checks executed!");
				}
			}
		};
		reloadAction.setText("check again");
		reloadAction.setToolTipText("redo checks");
		reloadAction.setImageDescriptor(PlatformUI.getWorkbench()
				.getSharedImages()
				.getImageDescriptor(ISharedImages.IMG_ELCL_SYNCED));
		reloadAction.setEnabled(true);
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
				File origFile = new File(path);

				// System.out.println("Closed File: " + origFile.getName());

				if (checkInfoMap.keySet().contains(origFile)) {
					CheckViewInformation activeCheckViewInformation = checkInfoMap
							.get(origFile);
					activeCheckViewInformation.closeView();
					checkInfoMap.remove(origFile);

					activeCheckViewInformation = null;
//					saveAction.setEnabled(false);

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
				
				File origFile = new File(path);
				if (origFile.exists()) {

					if (!checkInfoMap.keySet().contains(origFile)) {
						CheckViewInformation checkInfo = CheckViewInformationFactory
								.create(origFile, res);
						if (checkInfo != null) {
							checkInfo.createCheckProcess();
							checkInfo.createCheckViewTree(parent);
							checkInfoMap.put(origFile, checkInfo);
						}
					}

					activeCheckViewInformation = checkInfoMap
							.get(origFile);
					if (activeCheckViewInformation != null) {
						activeCheckViewInformation.getTreeViewer().getTree().setVisible(true);
						((GridData) activeCheckViewInformation.getTreeViewer().getTree().getLayoutData()).exclude = false;
					parent.layout();
					}
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

