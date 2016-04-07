package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import java.io.IOException;
import java.util.HashMap;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.EditorReference;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.McamPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

@SuppressWarnings("restriction")
public abstract class McamView<T extends McamPage> extends ViewPart implements
		IPartListener2 {

	private static final String EXTENSION_ID = "de.jabc.cinco.meta.plugin.mcam.runtime.extensionpoint";

	protected Bundle bundle = FrameworkUtil.getBundle(this.getClass());

	protected Class<T> genericParameterClass;

	private Composite parent;

	protected T activePage;
	protected TreeViewer viewer;
	protected IFile activeFile;

	private HashMap<String, T> pageMap = new HashMap<>();

	protected IAction doubleClickAction;
	protected IAction expandAllAction;
	protected IAction collapseAllAction;
	protected IAction reloadAction;

	protected Image iconRefresh;
	protected Image iconCollapseAll;
	protected Image iconExpandAll;

	public IFile getActiveFile() {
		return activeFile;
	}

	public T getActivePage() {
		return activePage;
	}

	public HashMap<String, T> getPageMap() {
		return pageMap;
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

		try {
			loadIcons();
		} catch (IOException e) {
			e.printStackTrace();
		}

		makeActions();
		contributeToActionBars();

		initView(parent);

		for (IEditorReference editor : PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow().getActivePage()
				.getEditorReferences()) {
			loadPageByEditor(editor);
		}
	}

	private void initControls() {
		viewer = activePage.getTreeViewer();

		// Create the help context id for the viewer's control
		PlatformUI.getWorkbench().getHelpSystem()
				.setHelp(viewer.getControl(), "mcamview.viewer");

		hookContextMenu();
		hookDoubleClickAction();
	}

	protected void hookContextMenu() {
		MenuManager menuMgr = new MenuManager("#PopupMenu");
		menuMgr.setRemoveAllWhenShown(true);
		menuMgr.addMenuListener(new IMenuListener() {
			public void menuAboutToShow(IMenuManager manager) {
				fillContextMenu(manager);
			}
		});
		Menu menu = menuMgr.createContextMenu(viewer.getControl());
		viewer.getControl().setMenu(menu);
		getSite().registerContextMenu(menuMgr, viewer);
	}

	protected void loadIcons() throws IOException {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.runtime");

		iconRefresh = new Image(EclipseUtils.getDisplay(),
				FileLocator.openStream(bundle, new Path("icons/refresh.gif"),
						true));

		iconCollapseAll = new Image(EclipseUtils.getDisplay(),
				FileLocator.openStream(bundle,
						new Path("icons/collapseall.png"), true));

		iconExpandAll = new Image(EclipseUtils.getDisplay(),
				FileLocator.openStream(bundle, new Path("icons/expandall.gif"),
						true));
	}

	abstract protected void fillLocalPullDown(IMenuManager manager);

	abstract protected void fillContextMenu(IMenuManager manager);

	abstract protected void fillLocalToolBar(IToolBarManager manager);

	protected void initView(Composite parent) {
	}

	protected void makeActions() {
		/*
		 * ------------------------------------------
		 */
		reloadAction = new Action() {
			public void run() {
				if (activePage != null)
					activePage.reload();
				refreshView();
			}
		};
		reloadAction.setText("Reload");
		reloadAction.setToolTipText("Reload");
		reloadAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconRefresh));

		/*
		 * ------------------------------------------
		 */
		doubleClickAction = new Action() {
			public void run() {
				ISelection selection = viewer.getSelection();
				Object obj = ((IStructuredSelection) selection)
						.getFirstElement();
				activePage.toggleExpand(obj);
				activePage.storeTreeState();
			}
		};

		/*
		 * ------------------------------------------
		 */
		expandAllAction = new Action() {
			public void run() {
				if (activePage != null) {
					activePage.getTreeViewer().expandAll();
					activePage.storeTreeState();
				}
			}
		};
		expandAllAction.setText("Expand all");
		expandAllAction.setToolTipText("Expand all");
		expandAllAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconExpandAll));

		/*
		 * ------------------------------------------
		 */
		collapseAllAction = new Action() {
			public void run() {
				if (activePage != null) {
					activePage.getTreeViewer().collapseAll();
					activePage.storeTreeState();
				}
			}
		};
		collapseAllAction.setText("Collapse all");
		collapseAllAction.setToolTipText("Collapse all");
		collapseAllAction.setImageDescriptor(ImageDescriptor
				.createFromImage(iconCollapseAll));
	}

	abstract protected void reloadViewState();

	protected void setActivePage(T activePage) {
		this.activePage = activePage;
	}

	protected void contributeToActionBars() {
		IActionBars bars = getViewSite().getActionBars();
		fillLocalPullDown(bars.getMenuManager());
		fillLocalToolBar(bars.getToolBarManager());
	}

	protected void hookDoubleClickAction() {
		activePage.getTreeViewer().addDoubleClickListener(
				new IDoubleClickListener() {
					public void doubleClick(DoubleClickEvent event) {
						doubleClickAction.run();
					}
				});
	}

	/**
	 * Passing the focus request to the viewer's control.
	 */
	public void setFocus() {
		// viewer.getControl().setFocus();
	}

	public void refreshView() {
		if (!parent.isDisposed()) {
			parent.layout(true, true);
			parent.redraw();
			parent.update();
		}
	}

	protected void editorChanged() {
		refreshView();
	}

	protected void activePageChanged() {
		reloadViewState();
	}

	/**
	 * Part Listener Methods
	 */
	@Override
	public void partActivated(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part active: "
		// + partRef.getTitle());
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part to top: "
		// + partRef.getTitle());
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part closed: "
		// + partRef.getTitle());
		closePage(partRef);
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName()
		// + "Part deactivated: " + partRef.getTitle());
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part opened: "
		// + partRef.getTitle());
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part hidden: "
		// + partRef.getTitle());
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName() + "Part visible: "
		// + partRef.getTitle());
		loadPageByEditor(partRef);
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		// System.out.println(this.getClass().getSimpleName()
		// + "Part input changed: " + partRef.getTitle());
	}

	public void closePage(IWorkbenchPartReference partRef) {
		if (partRef instanceof EditorReference) {
			IEditorPart editor = ((EditorReference) partRef).getEditor(true);
			if (editor instanceof DiagramEditor == false)
				return;

			T newPage = createPage(EclipseUtils.getIFile(editor));
			String pageId = newPage.getPageId();

			if (pageMap.keySet().contains(pageId)) {
				T page = pageMap.get(pageId);
				page.closeView();
				pageMap.remove(pageId);
				activePage = null;

				if (!parent.isDisposed()) {
					parent.layout(true);
					parent.redraw();
					parent.update();
				}
			}
		}
	}

	public void loadPageByEditor(IWorkbenchPartReference partRef) {
		if (partRef instanceof EditorReference) {
			IEditorPart editor = ((EditorReference) partRef).getEditor(true);
			if (editor instanceof DiagramEditor == false)
				return;

			T newPage = createPage(EclipseUtils.getIFile(editor));
			
			if (newPage == null)
				return;
			
			String pageId = newPage.getPageId();

			if (parent.isDisposed())
				return;

			if (activePage == null || !pageId.equals(activePage.getPageId())) {

				for (Control child : parent.getChildren()) {
					child.setVisible(false);
					if (child.getLayoutData() instanceof GridData)
						((GridData) child.getLayoutData()).exclude = true;
				}

				if (!pageMap.keySet().contains(pageId)) {
					try {
						newPage.initPage(parent, this);
						pageMap.put(pageId, newPage);
					} catch (IOException e) {
						e.printStackTrace();
					}
				}

				setActivePage(pageMap.get(pageId));
				reloadAction.run();
				activePage.getFrameComposite().setVisible(true);
				((GridData) activePage.getFrameComposite().getLayoutData()).exclude = false;

				initControls();
				activePageChanged();
			}
			editorChanged();
		}
	}

	public abstract T createPage(IFile file);

	protected PageFactory getPageFactory() {
		IConfigurationElement[] configElements = Platform
				.getExtensionRegistry().getConfigurationElementsFor(
						EXTENSION_ID);
		for (IConfigurationElement ce : configElements) {
			try {
				Object o = ce.createExecutableExtension("class");

				if (o instanceof PageFactory)
					return (PageFactory) o;

			} catch (CoreException e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	@Override
	public void dispose() {
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
				.removePartListener(this);
		super.dispose();
	}
}
