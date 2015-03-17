package ${ConflictViewPackage}.views;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.cinco.product.flowgraph.mcam.cli.FrameworkExecution;
import ${ConflictViewPackage}.util.MergeProcessTreeRenderer;
import info.scce.mcam.framework.processes.CheckProcess;
import info.scce.mcam.framework.processes.CompareProcess;
import info.scce.mcam.framework.processes.MergeProcess;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;

public class ConflictViewInformation {
	
	private IFile iFile = null;

	private File origFile = null;
	private File remoteFile = null;
	private File localFile = null;

	private Resource resource = null;
	
	private MergeProcess<${GraphModelName}Id, ${GraphModelName}Adapter> mp = null;
	private CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;
	
	private Tree tree = null;

	public ConflictViewInformation(File origFile, File remoteFile,
			File localFile, IFile iFile, Resource resource) {
		super();
		this.origFile = origFile;
		this.remoteFile = remoteFile;
		this.localFile = localFile;
		this.iFile = iFile;
		this.resource = resource;
		
		createMergeCheckProcess();
	}
	
	public void createMergeCheckProcess() {
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
				.executeMergePhase(localCompare, remoteCompare, mergeModel);
		cp = FrameworkExecution
				.executeCheckPhase(mergeModel);
	}
	
	public void createConflictViewTree(Composite parent) {
		tree = new Tree(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		// MergeProcessTreeRenderer treeRenderer = new MergeProcessTreeRenderer(
		// viewer.getTree(), mp, viewer.getControl().getShell());
		MergeProcessTreeRenderer<${GraphModelName}Id, ${GraphModelName}Adapter> treeRenderer = new MergeProcessTreeRenderer<${GraphModelName}Id, ${GraphModelName}Adapter>(
				tree, mp, tree.getShell());
		treeRenderer.createTree();
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

	public CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> getCp() {
		return cp;
	}

	public Tree getTree() {
		return tree;
	}
	
	
	
	
}

