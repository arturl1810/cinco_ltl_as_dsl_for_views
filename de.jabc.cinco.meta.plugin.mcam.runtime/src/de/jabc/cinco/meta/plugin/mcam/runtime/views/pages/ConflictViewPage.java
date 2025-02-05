package de.jabc.cinco.meta.plugin.mcam.runtime.views.pages;

import graphmodel.GraphModel;
import graphmodel.ModelElement;
import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.MergeInformation;
import info.scce.mcam.framework.processes.MergeInformation.MergeType;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.viewers.ViewerSorter;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider.IStyledLabelProvider;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.part.ViewPart;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.plugin.mcam.runtime.core.ChangeDeadlockException;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoMergeStrategy;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes.TreeNode;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.provider.ConflictViewTreeProvider;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.utils.EclipseUtils;

public abstract class ConflictViewPage<E extends _CincoId, M extends GraphModel, A extends _CincoAdapter<E, M>>
		extends McamPage {

	private ConflictViewTreeProvider<E, M, A> data;
	
	protected IFile iFile;
	protected Resource resource;

	private HashMap<String, Image> icons = new HashMap<>();

	private ConflictViewLabelProvider labelProvider = new ConflictViewLabelProvider();
	private ConflictViewNameSorter nameSorter = new ConflictViewNameSorter();
	private ConflictViewTypeSorter typeSorter = new ConflictViewTypeSorter();

	private List<ChangeModule<E, A>> changesDone = new ArrayList<ChangeModule<E, A>>();
	protected MergeProcess<E, A> mp = null;

	protected int activeFilter = 0;
	protected int activeSort = 0;

	private ConflictViewTypeFilter changedFilter = new ConflictViewTypeFilter(
			MergeType.CHANGED);
	private ConflictViewTypeFilter addedFilter = new ConflictViewTypeFilter(
			MergeType.ADDED);
	private ConflictViewTypeFilter deletedFilter = new ConflictViewTypeFilter(
			MergeType.DELETED);
	private ConflictViewTypeFilter conflictedFilter = new ConflictViewTypeFilter(
			MergeType.CONFLICTED);

	public ConflictViewPage(String pageId, IFile iFile, Resource resource) {
		super(pageId);
		this.iFile = iFile;
		this.resource = resource;
		
		this.mp = (MergeProcess<E, A>) createMp();
		this.data = new ConflictViewTreeProvider<E, M, A>(this);
	}

	/*
	 * Getter / Setter
	 */
	
	@Override
	public ConflictViewTreeProvider<E, M, A> getDataProvider() {
		return data;
	}

	public IFile getiFile() {
		return iFile;
	}

	public Resource getResource() {
		return resource;
	}

	public MergeProcess<E, A> getMp() {
		return mp;
	}

	@Override
	public DelegatingStyledCellLabelProvider getDefaultLabelProvider() {
		return new DelegatingStyledCellLabelProvider(labelProvider);
	}

	@Override
	public ViewerSorter getDefaultSorter() {
		return nameSorter;
	}

	public void setActiveFilter(int filter) {
		activeFilter = filter;
	}

	public int getActiveFilter() {
		return activeFilter;
	}

	public void setActiveSort(int sort) {
		activeSort = sort;
	}

	public int getActiveSort() {
		return activeSort;
	}

	public ViewerSorter getNameSorter() {
		return nameSorter;
	}

	public ViewerSorter getTypeSorter() {
		return typeSorter;
	}

	public ViewerFilter getConflictViewTypeFilter(MergeType type) {
		switch (type) {
		case ADDED:
			return addedFilter;
		case CHANGED:
			return changedFilter;
		case CONFLICTED:
			return conflictedFilter;
		case DELETED:
			return deletedFilter;
		default:
			return null;
		}
	}

	/*
	 * Methods
	 */
	@Override
	protected void loadIcons() {
		Bundle bundle = Platform
				.getBundle("de.jabc.cinco.meta.plugin.mcam.runtime");
		try {
			InputStream boxCheckedImgStream = FileLocator.openStream(bundle,
					new Path("icons/box_checked.png"), true);
			icons.put("boxChecked", new Image(EclipseUtils.getDisplay(),
					boxCheckedImgStream));

			InputStream boxUncheckedImgStream = FileLocator.openStream(bundle,
					new Path("icons/box_unchecked.png"), true);
			icons.put("boxUnchecked", new Image(EclipseUtils.getDisplay(),
					boxUncheckedImgStream));

			InputStream warningImgStream = FileLocator.openStream(bundle,
					new Path("icons/warning.png"), true);
			icons.put("warning", new Image(EclipseUtils.getDisplay(),
					warningImgStream));

			InputStream errorImgStream = FileLocator.openStream(bundle,
					new Path("icons/error.png"), true);
			icons.put("error", new Image(EclipseUtils.getDisplay(),
					errorImgStream));

			InputStream infoImgStream = FileLocator.openStream(bundle,
					new Path("icons/info.png"), true);
			icons.put("info", new Image(EclipseUtils.getDisplay(),
					infoImgStream));

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

//	@Override
//	public void reload() {
//		storeTreeState();
//		data.reset();
//		treeViewer.setInput(parentViewPart.getViewSite());
//		restoreTreeState();
//	}

	@SuppressWarnings("unchecked")
	@Override
	public void highlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof _CincoId) {
			getDataProvider().getMergeProcess().getMergeModelAdapter()
					.highlightElement((E) obj);
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void initPage(Composite parent, ViewPart parentViewPart)
			throws IOException {
		
		super.initPage(parent, parentViewPart);

		if (mp == null)
			return;
		
		runInitialChangeExecution();

		treeViewer.addSelectionChangedListener(new ISelectionChangedListener() {

			public void selectionChanged(SelectionChangedEvent event) {
				if (event.getSelection() instanceof IStructuredSelection) {
					IStructuredSelection selection = (IStructuredSelection) event
							.getSelection();

					Object obj = null;
					if (selection.getFirstElement() instanceof TreeNode)
						obj = ((TreeNode) selection.getFirstElement())
								.getData();

					if (obj instanceof _CincoId)
						mp.getMergeModelAdapter().highlightElement((E) obj);

					if (obj instanceof ChangeModule<?, ?>) {
						ChangeModule<E, A> change = (ChangeModule<E, A>) obj;
						if (!changesDone.contains(change)) {
							if (change.canPreExecute(mp.getMergeModelAdapter())
									&& change.canExecute(mp
											.getMergeModelAdapter())
									&& change.canPostExecute(mp
											.getMergeModelAdapter())) {
								change.preExecute(mp.getMergeModelAdapter());
								change.execute(mp.getMergeModelAdapter());
								change.postExecute(mp.getMergeModelAdapter());

								changesDone.add(change);
							} else {
								MessageDialog.openError(treeViewer.getTree()
										.getShell(),
										"Change could not be executed!",
										"Change could not be executed! \n"
												+ change.toString());
							}

						} else if (changesDone.contains(change)) {
							if (change.canUndoPreExecute(mp
									.getMergeModelAdapter())
									&& change.canUndoExecute(mp
											.getMergeModelAdapter())
									&& change.canUndoPostExecute(mp
											.getMergeModelAdapter())) {
								change.undoPostExecute(mp
										.getMergeModelAdapter());
								change.undoExecute(mp.getMergeModelAdapter());
								change.undoPreExecute(mp.getMergeModelAdapter());

								changesDone.remove(change);
							} else {
								MessageDialog.openError(treeViewer.getTree()
										.getShell(),
										"Change could not be reverted!",
										"Change could not be reverted! \n"
												+ change.toString());
							}
						}
					}
					treeViewer.refresh();
				}
			}
		});
	}

	public void runInitialChangeExecution() {
		mp.analyzeGraphCompares();

		_CincoMergeStrategy<E, A> strategy = new _CincoMergeStrategy<E, A>();

		try {
			changesDone = strategy.executeChanges((A) mp
					.getMergeModelAdapter(), mp.getMergeInformationMap()
					.values(), false);
		} catch (ChangeDeadlockException e) {
			System.err.println(e.getMessage());
			// for (ChangeModule<T, _CincoAdapter<T, M, W>> change : e
			// .getChangesToDo()) {
			// System.err.println(" - " + change.id + ": " + change);
			// }
			// changesDone = e.getChangesDone();
		}
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void openAndHighlight(Object obj) {
		obj = getTreeNodeData(obj);
		if (obj instanceof _CincoId) {
			_CincoId id = (_CincoId) obj;
			Object element = id.getElement();

			if (element instanceof ModelElement) {
				ModelElement me = (ModelElement) element;
				IEditorPart editor = openEditor(me.getRootElement());

				IFile iFile = EclipseUtils.getIFile(editor);
				Resource resource = EclipseUtils.getResource(editor);

				_CincoAdapter<E, M> adapter = getAdapter(iFile, resource);
				adapter.highlightElement(adapter.getIdByString(me.getId()));

				// if (me.getRootElement() instanceof Process) {
				// CProcess wrapper =
				// data.getUtils().getProcessWrapperFromEditor(editorPart);
				// data.getUtils().highlightElement(wrapper, me.getId());
				// }
				// if (me.getRootElement() instanceof GUI) {
				// CGUI wrapper =
				// data.getUtils().getGuiWrapperFromEditor(editorPart);
				// data.getUtils().highlightElement(wrapper, me.getId());
				// }
			}
			if (element instanceof GraphModel) {
				openEditor((GraphModel) element);
			}
		}
	}
	
	protected abstract MergeProcess<E, A> createMp();

	/*
	 * Provider / Classes for TreeViewer
	 */
	private class ConflictViewLabelProvider extends LabelProvider implements
	IStyledLabelProvider {

		public ConflictViewLabelProvider() {
			super();
		}

		@SuppressWarnings("unchecked")
		public Image getImage(Object element) {
			element = getTreeNodeData(element);

			if (element instanceof _CincoId) {
				E id = (E) element;
				if (getDataProvider().getMergeProcess()
						.getMergeInformationMap().get(id)
						.getListOfConflictedChangeSets().size() > 0)
					return icons.get("error");
				return icons.get("info");
			}
			if (element instanceof ChangeModule<?, ?>) {
				ChangeModule<E, A> change = (ChangeModule<E, A>) element;
				if (changesDone.contains(change))
					return icons.get("boxChecked");
				return icons.get("boxUnchecked");
			}
			if (element instanceof Set<?>)
				return icons.get("warning");
			return null;
		}

		/*
		 * @see ILabelProvider#getText(Object)
		 */
		@SuppressWarnings("unchecked")
		public String getText(Object element) {
			element = getTreeNodeData(element);

			if (element instanceof _CincoId)
				return ((E) element).toString();
			if (element instanceof ChangeModule<?, ?>) {
				ChangeModule<E, A> change = (ChangeModule<E, A>) element;
				if (getDataProvider().getMergeProcess()
						.getMergeInformationMap().get(change.id)
						.getLocalChanges().contains(change))
					return "(L) " + change.toString();
				if (getDataProvider().getMergeProcess()
						.getMergeInformationMap().get(change.id)
						.getRemoteChanges().contains(change))
					return "(R) " + change.toString();
			}
			if (element instanceof Set<?>) {
				for (MergeInformation<E, A> mergeInfo : mp.getMergeInformationMap().values()) {
					int i = 0;
					for (Set<ChangeModule<E, A>> conflictSet : mergeInfo
							.getListOfConflictedChangeSets()) {
						i++;
						if (conflictSet
								.equals((Set<ChangeModule<E, A>>) element))
							return "Conflict " + i;
					}
				}
				return "Conflict";
			}
			return "unknown";
		}

		@Override
		public StyledString getStyledText(Object arg0) {
			// TODO Auto-generated method stub
			return null;
		}

	}

	private class ConflictViewNameSorter extends ViewerSorter {
		private ArrayList<MergeType> typeSorting = new ArrayList<>();

		public ConflictViewNameSorter() {
			super();
			typeSorting.add(MergeType.CONFLICTED);
			typeSorting.add(MergeType.CHANGED);
			typeSorting.add(MergeType.ADDED);
			typeSorting.add(MergeType.DELETED);
		}

		@Override
		public int category(Object element) {
			if (element instanceof _CincoId)
				return 1;
			if (element instanceof Set<?>)
				return 2;
			return 3;
		}

		@SuppressWarnings("unchecked")
		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {
			e1 = getTreeNodeData(e1);
			e2 = getTreeNodeData(e2);

			int cat1 = category(e1);
			int cat2 = category(e2);
			if (cat1 != cat2)
				return cat1 - cat2;

			if (e1 instanceof _CincoId && e2 instanceof _CincoId) {
				E id1 = (E) e1;
				E id2 = (E) e2;
				Object input = viewer.getInput();
				if (input instanceof MergeProcess<?, ?>) {
					MergeProcess<E, A> mp = (MergeProcess<E, A>) input;
					MergeType type1 = mp.getMergeInformationMap().get(id1)
							.getType();
					MergeType type2 = mp.getMergeInformationMap().get(id2)
							.getType();
					return typeSorting.indexOf(type1)
							- typeSorting.indexOf(type2);
				}
			}

			return super.compare(viewer, e1, e2);
		}

	}

	public class ConflictViewTypeSorter extends ViewerSorter {

		private ArrayList<MergeType> typeSorting = new ArrayList<>();

		public ConflictViewTypeSorter() {
			super();
			typeSorting.add(MergeType.CONFLICTED);
			typeSorting.add(MergeType.CHANGED);
			typeSorting.add(MergeType.ADDED);
			typeSorting.add(MergeType.DELETED);
		}

		@Override
		public int category(Object element) {
			if (element instanceof _CincoId)
				return 1;
			if (element instanceof Set<?>)
				return 2;
			return 3;
		}

		@SuppressWarnings("unchecked")
		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {
			e1 = getTreeNodeData(e1);
			e2 = getTreeNodeData(e2);

			int cat1 = category(e1);
			int cat2 = category(e2);
			if (cat1 != cat2)
				return cat1 - cat2;

			if (e1 instanceof _CincoId && e2 instanceof _CincoId) {
				E id1 = (E) e1;
				E id2 = (E) e2;
				Object input = viewer.getInput();
				if (input instanceof MergeProcess<?, ?>) {
					MergeProcess<E, A> mp = (MergeProcess<E, A>) input;
					MergeType type1 = mp.getMergeInformationMap().get(id1)
							.getType();
					MergeType type2 = mp.getMergeInformationMap().get(id2)
							.getType();
					return typeSorting.indexOf(type1)
							- typeSorting.indexOf(type2);
				}
			}

			return super.compare(viewer, e1, e2);
		}

	}

	public class ConflictViewTypeFilter extends ViewerFilter {

		MergeType type = MergeType.UNCHANGED;

		public ConflictViewTypeFilter(MergeType type) {
			super();
			this.type = type;
		}

		@SuppressWarnings("unchecked")
		@Override
		public boolean select(Viewer viewer, Object parentElement,
				Object element) {
			element = getTreeNodeData(element);
			if (element instanceof Set<?>
					|| element instanceof ChangeModule<?, ?>)
				return true;
			if (element instanceof _CincoId) {
				E id = (E) element;
				return getDataProvider().getMergeProcess()
						.getMergeInformationMap().get(id).getType()
						.equals(type);
			}
			return false;
		}
	}
}
