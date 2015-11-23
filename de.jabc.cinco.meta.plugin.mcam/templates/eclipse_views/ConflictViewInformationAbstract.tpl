package ${McamViewProject};

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;

public abstract class ConflictViewInformation {

	protected IFile iFile = null;

	protected File origFile = null;
	protected File remoteFile = null;
	protected File localFile = null;

	protected Resource resource = null;

	protected TreeViewer treeViewer = null;
	protected int activeFilter = 0;
	protected int activeSort = 0;

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

	public void closeView() {
		treeViewer.getControl().dispose();
	}

	public abstract void createMergeProcess();

	public abstract void runInitialChangeExecution();

	public abstract void createConflictViewTree(Composite parent);

}

