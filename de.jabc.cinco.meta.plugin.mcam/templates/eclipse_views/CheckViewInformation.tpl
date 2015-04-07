package ${ViewPackage}.views;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;
import ${ViewPackage}.util.CheckProcessTreeRenderer;
import info.scce.mcam.framework.processes.CheckProcess;

import java.io.File;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;

public class CheckViewInformation {
	private File file = null;
	private Resource resource = null;
	
	private CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;
	
	private Tree tree = null;

	public CheckViewInformation(File file, Resource resource) {
		super();
		this.file = file;
		this.resource = resource;
	}
	
	public void createCheckProcess() {
		${GraphModelName}Adapter model = FrameworkExecution
				.initApiAdapterFromResource(resource, file);

		cp = FrameworkExecution
				.createCheckPhase(model);
		cp.checkModel();
	}
	
	public void createCheckViewTree(Composite parent) {
		tree = new Tree(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		tree.setLayout(new GridLayout(1, false));
		tree.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		CheckProcessTreeRenderer treeRenderer = new CheckProcessTreeRenderer(
				tree, cp, tree.getShell());
		treeRenderer.createTree();
		treeRenderer.runInitialChangeExecution();
	}

	public File getFile() {
		return file;
	}

	public CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> getCp() {
		return cp;
	}

	public Tree getTree() {
		return tree;
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

