package ${ViewPackage}.views;

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import info.scce.cinco.product.${GraphModelName?lower_case}.mcam.cli.FrameworkExecution;
import info.scce.mcam.framework.processes.CheckProcess;

import java.io.File;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.swt.SWT;
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
				.executeCheckPhase(model);
	}
	
	public void createCheckViewTree(Composite parent) {
		tree = new Tree(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		// MergeProcessTreeRenderer treeRenderer = new MergeProcessTreeRenderer(
		// viewer.getTree(), mp, viewer.getControl().getShell());
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
}

