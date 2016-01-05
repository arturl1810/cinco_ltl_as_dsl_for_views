package ${McamViewBasePackage};

import ${McamViewBasePackage}.CheckResourceChangeListener;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;

@SuppressWarnings("restriction")
public class CheckView extends ViewPart implements IPartListener2 {

	/**
	 * The ID of the view as specified by the extension.
	 */
	public static final String ID = "${McamViewBasePackage}.CheckView";

	private Composite parent = null;

	private Action reloadAction;
	private Action expandAction;
	private Action collapseAction;

	private CheckViewInformation activeCheckViewInformation = null;

	private HashMap<String, CheckViewInformation> checkInfoMap = new HashMap<>();

	private String refreshIconPath = "icons/refresh.gif";
	private String expandAllIconPath = "icons/expandall.gif";
	private String collapseAllIconPath = "icons/collapseall.png";

	private Image refreshImg = null;
	private Image expandAllImg = null;
	private Image collapseAllImg = null;

	private CheckResourceChangeListener resourceChangeListener;

	/**
	 * The constructor.
	 */
	public CheckView() {
	}
	
	public CheckViewInformation getActiveCheckViewInformation() {
		return activeCheckViewInformation;
	}

	public HashMap<String, CheckViewInformation> getCheckInfoMap() {
		return checkInfoMap;
	}
	
	public Composite getParent() {
		return parent;
	}

	/**
	 * This is a callback that will allow us to create the viewer and initialize
	 * it.
	 */

	private void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam");
		try {
			InputStream refreshImgStream = FileLocator.openStream(bundle,
					new Path(refreshIconPath), true);
			refreshImg = new Image(getDisplay(), refreshImgStream);
			InputStream expandAllImgStream = FileLocator.openStream(bundle,
					new Path(expandAllIconPath), true);
			expandAllImg = new Image(getDisplay(), expandAllImgStream);
			InputStream collapseAllImgStream = FileLocator.openStream(bundle,
					new Path(collapseAllIconPath), true);
			collapseAllImg = new Image(getDisplay(), collapseAllImgStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public Display getDisplay() {
		Display display = Display.getCurrent();
		// may be null if outside the UI thread
		if (display == null)
			display = Display.getDefault();
		return display;
	}

	public void createPartControl(Composite parent) {

		this.parent = parent;
		this.parent.setLayout(new GridLayout(1, true));
		this.parent.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.addPartListener(this);

		resourceChangeListener = new CheckResourceChangeListener(this);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceChangeListener);

		loadIcons();
		makeActions();
		contributeToActionBars();

		for (IEditorReference editor : PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow().getActivePage()
				.getEditorReferences()) {
			loadPageByEditor(editor);
		}
	}

	@Override
	public void dispose() {
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
		.removePartListener(this);

		ResourcesPlugin.getWorkspace().removeResourceChangeListener(
		resourceChangeListener);
		
		super.dispose();
	}

	private void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	private void fillLocalPullDown(IMenuManager manager) {
		// manager.add(reloadAction);
		// manager.add(new Separator());
	}

	private void fillLocalToolBar(IToolBarManager manager) {
		manager.add(reloadAction);
		manager.add(expandAction);
		manager.add(collapseAction);
	}

	private void makeActions() {
		reloadAction = new Action() {
			public void run() {
				if (activeCheckViewInformation != null) {
					activeCheckViewInformation.closeView();
					activeCheckViewInformation.createCheckProcess();
					activeCheckViewInformation.createCheckViewTree(parent);

					activeCheckViewInformation.getTreeViewer().expandAll();

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
		reloadAction.setImageDescriptor(ImageDescriptor
				.createFromImage(refreshImg));
		reloadAction.setEnabled(true);

		/*
		* ------------------------------------------
		*/
		expandAction = new Action() {
			public void run() {
				if (activeCheckViewInformation != null) {
					activeCheckViewInformation.getTreeViewer().expandAll();
				}
			}
		};
		expandAction.setText("expand all");
		expandAction.setToolTipText("expand all");
		expandAction.setImageDescriptor(ImageDescriptor
				.createFromImage(expandAllImg));
		expandAction.setEnabled(true);

		/*
		* ------------------------------------------
		*/
		collapseAction = new Action() {
			public void run() {
				if (activeCheckViewInformation != null) {
					activeCheckViewInformation.getTreeViewer().collapseAll();
				}
			}
		};
		collapseAction.setText("collapse all");
		collapseAction.setToolTipText("collapse all");
		collapseAction.setImageDescriptor(ImageDescriptor
				.createFromImage(collapseAllImg));
		collapseAction.setEnabled(true);

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

				if (checkInfoMap.keySet().contains(origFile.getAbsolutePath())) {
					CheckViewInformation activeCheckViewInformation = checkInfoMap
							.get(origFile.getAbsolutePath());
					activeCheckViewInformation.closeView();
					checkInfoMap.remove(origFile.getAbsolutePath());

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
		loadPageByEditor(partRef);
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		// System.out.println("Part input changed: " + partRef.getTitle());
	}

	private void loadPageByEditor(IWorkbenchPartReference partRef) {
		if (partRef instanceof EditorReference) {
			IEditorPart editor = ((EditorReference) partRef).getEditor(true);
			if (editor instanceof DiagramEditor == false)
				return;

			IFile file = (IFile) editor.getEditorInput().getAdapter(IFile.class);

			Resource res = null;
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
				if (child.getLayoutData() instanceof GridData)
					((GridData) child.getLayoutData()).exclude = true;
			}

			if (file != null && res != null) {
				String path = file.getRawLocation().toOSString();
				
				File origFile = new File(path);
				if (origFile.exists()) {

					if (!checkInfoMap.keySet().contains(origFile.getAbsolutePath())) {
						CheckViewInformation checkInfo = CheckViewInformationFactory
								.create(origFile, res);
						if (checkInfo != null) {
							checkInfo.createCheckProcess();
							checkInfo.createCheckViewTree(parent);
							checkInfoMap.put(origFile.getAbsolutePath(), checkInfo);
						}
					}

					activeCheckViewInformation = checkInfoMap
							.get(origFile.getAbsolutePath());
					if (activeCheckViewInformation != null) {
						reloadAction.run();
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

}

