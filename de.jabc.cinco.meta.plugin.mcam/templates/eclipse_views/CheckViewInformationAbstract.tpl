package ${McamViewBasePackage};

import java.io.File;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;

public abstract class CheckViewInformation {
	protected File file = null;
	protected Resource resource = null;
	
	protected TreeViewer treeViewer = null;
	
	public CheckViewInformation(File file, Resource resource) {
		super();
		this.file = file;
		this.resource = resource;
	}

	public abstract void createCheckProcess();

	public abstract void createCheckViewTree(Composite parent);

	public TreeViewer getTreeViewer() {
		return treeViewer;
	}
	
	public void closeView() {
		treeViewer.getControl().dispose();
	}
	
	public File getFile() {
		return file;
	}
}

