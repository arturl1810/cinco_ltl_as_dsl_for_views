package de.jabc.cinco.meta.plugin.mcam.runtime.views.pages;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.AbstractTreeViewer;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.viewers.ViewerSorter;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.TreeProvider;

public abstract class McamPage {
	
	protected Composite parent;
	protected ViewPart parentViewPart;

	protected TreeViewer treeViewer;
	protected Composite frameComposite;

	protected String pageId;
	
	protected Bundle bundle = FrameworkUtil.getBundle(this.getClass());
	protected Image iconClearSearch = PlatformUI.getWorkbench()
			.getSharedImages().getImage(ISharedImages.IMG_ELCL_REMOVE);

	protected HashMap<String, Boolean> expandState = new HashMap<>();
	
	protected McamFullTextFilter defaultFilterFullText = new McamFullTextFilter();
	protected McamContentProvider defaultContentProvider = new McamContentProvider();
	
	public McamPage(String id) {
		this.pageId = id;
	}

	public Composite getFrameComposite() {
		return frameComposite;
	}

	public TreeViewer getTreeViewer() {
		return treeViewer;
	}

	public String getPageId() {
		return pageId;
	}
	
	public McamFullTextFilter getDefaultFilterFullText() {
		return defaultFilterFullText;
	}

	public void setDefaultFilterFullText(McamFullTextFilter defaultFilterFullText) {
		this.defaultFilterFullText = defaultFilterFullText;
	}

	public McamContentProvider getDefaultContentProvider() {
		return defaultContentProvider;
	}

	public void setDefaultContentProvider(
			McamContentProvider defaultContentProvider) {
		this.defaultContentProvider = defaultContentProvider;
	}

	protected void loadIcons() throws IOException {
		
	}

	public void initPage(Composite parent, ViewPart parentViewPart) throws IOException {
		this.parent = parent;
		this.parentViewPart = parentViewPart;

		loadIcons();

		frameComposite = new Composite(parent, SWT.NONE);
		GridLayout gridLayout = new GridLayout(4, false);
		frameComposite.setLayout(gridLayout);
		frameComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true,
				true));

		Text searchField = new Text(frameComposite, SWT.SINGLE | SWT.BORDER);
		GridData gridData = new GridData(SWT.FILL, SWT.NONE, true, false);
		searchField.setLayoutData(gridData);

		searchField.addModifyListener(new ModifyListener() {
			@Override
			public void modifyText(ModifyEvent e) {
				Text text = (Text) e.widget;
				treeViewer.removeFilter(defaultFilterFullText);
				defaultFilterFullText.searchString= text.getText();
				treeViewer.addFilter(defaultFilterFullText);
				if (text.getText().length() > 0)
					treeViewer.expandAll();
			}
		});

		Button buttonClearSearch = new Button(frameComposite, SWT.NONE);
		buttonClearSearch.setImage(iconClearSearch);
		buttonClearSearch.setToolTipText("clear search field");
		buttonClearSearch.addSelectionListener(new SelectionListener() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				widgetDefaultSelected(e);
			}

			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
				searchField.setText("");
			}
		});

		treeViewer = new TreeViewer(frameComposite, SWT.H_SCROLL | SWT.V_SCROLL);

		GridData gridDataViewer = new GridData(SWT.FILL, SWT.FILL, true, true);
		gridDataViewer.horizontalSpan = 4;

		treeViewer.getTree().setLayoutData(gridDataViewer);
		treeViewer.setContentProvider(defaultContentProvider);
		treeViewer.setLabelProvider(getDefaultLabelProvider());
		treeViewer.setSorter(getDefaultSorter());

		treeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			public void selectionChanged(SelectionChangedEvent event) {
				if (event.getSelection() instanceof IStructuredSelection) {
					IStructuredSelection selection = (IStructuredSelection) event
							.getSelection();
					highlight(selection.getFirstElement());
					treeViewer.refresh();
				}
			}
		});

		/*
		treeViewer.addDragSupport(DND.DROP_MOVE | DND.DROP_COPY,
				new Transfer[] { LocalSelectionTransfer.getTransfer() },
				new DragSourceAdapter() {

					@Override
					public void dragStart(DragSourceEvent event) {
						ISelection sel = treeViewer.getSelection();
						if (sel instanceof TreeSelection) {
							TreeSelection treeSel = (TreeSelection) treeViewer
									.getSelection();
							List<Object> selItems = new ArrayList<Object>();

							Object firstELem = treeSel.getFirstElement();
							if (firstELem instanceof TreeNode)
								selItems.add(((TreeNode) firstELem).getData());
							sel = new StructuredSelection(selItems);
						}
						LocalSelectionTransfer.getTransfer().setSelection(sel);
					}

				});
		*/

		treeViewer.getTree().addListener(SWT.Expand, new Listener() {
			public void handleEvent(Event e) {
				storeTreeState();
				expandState.put(
						getPathIdentifier(((TreeItem) e.item).getData()), true);
			}
		});
		treeViewer.getTree().addListener(SWT.Collapse, new Listener() {
			public void handleEvent(Event e) {
				storeTreeState();
				expandState.put(
						getPathIdentifier(((TreeItem) e.item).getData()), false);
			}
		});

		treeViewer.setInput(parentViewPart.getViewSite());

		frameComposite.pack();
	}

	public void storeTreeState() {
		expandState.clear();
		ArrayList<TreeItem> list = new ArrayList<TreeItem>();
		for (TreeItem item : treeViewer.getTree().getItems()) {
			list.add(item);
			list.addAll(getAllTreeItems(item));
		}

		for (TreeItem treeItem : list) {
			expandState.put(getPathIdentifier(treeItem.getData()),
					treeItem.getExpanded());
		}
	}

	public void restoreTreeState() {
		treeViewer.expandAll();

		ArrayList<TreeItem> list = new ArrayList<TreeItem>();
		for (TreeItem item : treeViewer.getTree().getItems()) {
			list.add(item);
			list.addAll(getAllTreeItems(item));
		}

		for (TreeItem treeItem : list) {
			Boolean expanded = expandState.get(getPathIdentifier(treeItem
					.getData()));
			if (expanded != null) {
				treeItem.setExpanded(expanded);
			}
		}
	}
	
	public void selectTreeItem(IFile file) {
		storeTreeState();
		
		ArrayList<TreeItem> list = new ArrayList<TreeItem>();
		for (TreeItem item : treeViewer.getTree().getItems()) {
			list.add(item);
			list.addAll(getAllTreeItems(item));
		}
		
		for (TreeItem treeItem : list) {
			if (treeItem.getText().contains(file.getName())) {
				treeViewer.setSelection(new StructuredSelection(treeItem.getData()), true);
				TreeItem item = treeItem;
				while (item != null) {
					expandState.put(getPathIdentifier(item.getData()),
							true);
					item = item.getParentItem();
				}
			}
		}
		
		restoreTreeState();
	}

	private String getPathIdentifier(Object obj) {
		if (obj instanceof TreeNode)
			return ((TreeNode) obj).getPathIdentifier();
		return "";
	}

	protected Object getTreeNodeData(Object obj) {
		if (obj instanceof TreeNode)
			return ((TreeNode) obj).getData();
		return obj;
	}

	private List<TreeItem> getAllTreeItems(TreeItem item) {
		ArrayList<TreeItem> list = new ArrayList<TreeItem>();
		for (TreeItem treeItem : item.getItems()) {
			list.add(treeItem);
			list.addAll(getAllTreeItems(treeItem));
		}
		return list;
	}
	
	public void closeView() {
		frameComposite.dispose();
	}

	public void toggleExpand(Object obj) {
		if (obj instanceof TreeNode) {
			ArrayList<TreeItem> list = new ArrayList<TreeItem>();
			for (TreeItem item : treeViewer.getTree().getItems()) {
				list.add(item);
				list.addAll(getAllTreeItems(item));
			}
			for (TreeItem treeItem : list) {
				if (treeItem.getData() == obj) {
					if (treeItem.getExpanded()) {
						treeViewer.collapseToLevel(obj,
								AbstractTreeViewer.ALL_LEVELS);
						expandState.put(getPathIdentifier(treeItem.getData()),
								false);
					} else {
						treeViewer.expandToLevel(obj, 1);
						expandState.put(getPathIdentifier(treeItem.getData()),
								true);
					}
					return;
				}
			}
		}
	}

	abstract public LabelProvider getDefaultLabelProvider();

	abstract public ViewerSorter getDefaultSorter();

	abstract public void reload();
	
	abstract public void highlight(Object obj);
	
	abstract public TreeProvider getDataProvider(); 
	
	/*
	 * Provider / Classes for TreeViewer
	 */
	private class McamContentProvider implements IStructuredContentProvider,
			ITreeContentProvider {

		private final Object[] EMPTY_ARRAY = new Object[0];

		public void inputChanged(Viewer v, Object oldInput, Object newInput) {
		}

		public void dispose() {
		}

		public Object[] getElements(Object parent) {
			if (parent.equals(parentViewPart.getViewSite())) {
				if (getDataProvider() != null && getDataProvider().isResetted()) 
					getDataProvider().load(this);
				return getChildren(getDataProvider().getTree());
			}
			return getChildren(parent);
		}

		public Object getParent(Object child) {
			if (child instanceof TreeNode)
				return ((TreeNode) child).getParent();
			return null;
		}

		public Object[] getChildren(Object parent) {
			if (parent instanceof TreeNode)
				return ((TreeNode) parent).getChildren().toArray();
			return EMPTY_ARRAY;
		}

		public boolean hasChildren(Object parent) {
			return getChildren(parent).length > 0;
		}

	}

	private class McamFullTextFilter extends ViewerFilter {

		private String searchString;

		@Override
		public boolean select(Viewer viewer, Object parentElement,
				Object element) {

			if (searchString.length() > 0) {
				if (compare(getDefaultLabelProvider().getText(element)))
					return true;
				if (compare(getDefaultLabelProvider().getText(parentElement)))
					return true;
				if (element instanceof TreeNode)
					if (compare((TreeNode) element))
						return true;
				return false;
			}
			return true;
		}

		private boolean compare(TreeNode element) {
			if (compare(getDefaultLabelProvider().getText(element)))
				return true;
			for (TreeNode childElement : element.getChildren()) {
				if (compare(childElement))
					return true;
			}
			return false;
		}

		private boolean compare(String string) {
			if (string.toLowerCase().contains(searchString.toLowerCase()))
				return true;
			return false;
		}
	}
}

