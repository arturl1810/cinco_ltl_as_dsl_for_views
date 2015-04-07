package ${ViewPackage}.views;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;
import ${ViewPackage}.util.MergeProcessTreeRenderer;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;

public class ConflictViewInformation {
	
	private IFile iFile = null;

	private File origFile = null;
	private File remoteFile = null;
	private File localFile = null;

	private Resource resource = null;
	
	private MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;
	
	private Tree tree = null;

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

	public Tree getTree() {
		return tree;
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
		mp.analyzeGraphCompares();
	}
	
	public void createConflictViewTree(Composite parent) {
		tree = new Tree(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		tree.setLayout(new GridLayout(1, false));
		tree.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		MergeProcessTreeRenderer treeRenderer = new MergeProcessTreeRenderer(
				tree, mp, tree.getShell());
		treeRenderer.createTree();

		treeRenderer.runInitialChangeExecution();
	}

	public void sortByState() {
		System.out.println("Sorting Tree by state...");
		System.out.println(tree.getClass());
		System.out.println("Items (before): " + tree.getItemCount());
		
		Tree dummyTree = new Tree(tree.getParent(), SWT.BORDER);
		
		for (TreeItem treeItem : tree.getItems()) {
			System.out.println(treeItem.getClass());
		}
	}

	public void closeView() {
		if (tree.isDisposed())
			return;

		for (Listener listener : tree.getListeners(SWT.MouseDoubleClick)) {
			tree.removeListener(SWT.MouseDoubleClick, listener);
		}
		for (Listener listener : tree.getListeners(SWT.MouseUp)) {
			tree.removeListener(SWT.MouseUp, listener);
		}
		for (Listener listener : tree.getListeners(SWT.MouseDown)) {
			tree.removeListener(SWT.MouseDown, listener);
		}
		tree.dispose();
	}
	
	
}

