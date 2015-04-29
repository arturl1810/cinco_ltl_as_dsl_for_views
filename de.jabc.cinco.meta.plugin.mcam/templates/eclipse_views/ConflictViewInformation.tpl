package ${ViewPackage}.views;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;

import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;
import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.strategies.${GraphModelName}MergeStrategy;
import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.util.ChangeDeadlockException;

import ${ViewPackage}.util.MergeProcessContentProvider;
import ${ViewPackage}.util.MergeProcessLabelProvider;

import info.scce.mcam.framework.modules.ChangeModule;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.File;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;

public class ConflictViewInformation {
	
	private IFile iFile = null;

	private File origFile = null;
	private File remoteFile = null;
	private File localFile = null;

	private Resource resource = null;
	
	private MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;

	private List<ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>> changesDone;
	
	private TreeViewer treeViewer = null;
	private int activeFilter = 0;
	private int activeSort = 0;

	public ConflictViewInformation(File origFile, File remoteFile,
			File localFile, IFile iFile, Resource resource) {
		super();
		this.origFile = origFile;
		this.remoteFile = remoteFile;
		this.localFile = localFile;
		this.iFile = iFile;
		this.resource = resource;
	}

	public File getOrigFile() {
		return origFile;
	}

	public File getRemoteFile() {
		return remoteFile;
	}

	public File getLocalFile() {
		return localFile;
	}

	public IFile getIFile() {
		return iFile;
	}

	public MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> getMp() {
		return mp;
	}

	public TreeViewer getTreeViewer() {
		return treeViewer;
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

	public void createMergeProcess() {
		${GraphModelName}Adapter orig = FrameworkExecution.initApiAdapter(origFile);
		${GraphModelName}Adapter local = FrameworkExecution.initApiAdapter(localFile);
		${GraphModelName}Adapter remote = FrameworkExecution.initApiAdapter(remoteFile);

		${GraphModelName}Adapter mergeModel = FrameworkExecution
				.initApiAdapterFromResource(resource, origFile);

		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> localCompare = FrameworkExecution
				.executeComparePhase(orig, local);
		CompareProcess<${GraphModelName}Id, ${GraphModelName}Adapter> remoteCompare = FrameworkExecution
				.executeComparePhase(orig, remote);
		mp = FrameworkExecution
				.createMergePhase(localCompare, remoteCompare, mergeModel);
	}
	
	public void createConflictViewTree(Composite parent) {
		treeViewer = new TreeViewer(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		treeViewer.setContentProvider(new MergeProcessContentProvider());
		treeViewer.setLabelProvider(new MergeProcessLabelProvider(mp,
				changesDone));
		treeViewer.setInput(mp);
		treeViewer.getTree().setLayout(new GridLayout(1, false));
		treeViewer.getTree().setLayoutData(
				new GridData(SWT.FILL, SWT.FILL, true, true));

		treeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			@SuppressWarnings("unchecked")
			public void selectionChanged(SelectionChangedEvent event) {
				if (event.getSelection() instanceof IStructuredSelection) {
					IStructuredSelection selection = (IStructuredSelection) event
							.getSelection();
					if (selection.getFirstElement() instanceof ${GraphModelName}Id)
						mp.getMergeModelAdapter().highlightElement(
								(${GraphModelName}Id) selection.getFirstElement());
					if (selection.getFirstElement() instanceof ChangeModule<?, ?>) {
						ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change = (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter>) selection
								.getFirstElement();
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
		
		${GraphModelName}MergeStrategy strategy = new ${GraphModelName}MergeStrategy();

		try {
			changesDone = strategy.executeChanges((${GraphModelName}Adapter) mp
					.getMergeModelAdapter(), mp.getMergeInformationMap()
					.values(), false);
		} catch (ChangeDeadlockException e) {
			System.err.println(e.getMessage());
			for (ChangeModule<${GraphModelName}Id, ${GraphModelName}Adapter> change : e
					.getChangesToDo()) {
				System.err.println(" - " + change.id + ": " + change);
			}
			changesDone = e.getChangesDone();
		}
	}

	public void closeView() {
		treeViewer.getControl().dispose();
	}
	
	
}

