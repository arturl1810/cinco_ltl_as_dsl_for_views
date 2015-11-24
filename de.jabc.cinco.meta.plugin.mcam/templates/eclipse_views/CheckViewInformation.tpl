package ${ViewViewPackage};

import ${AdapterPackage}.${GraphModelName}Adapter;
import ${AdapterPackage}.${GraphModelName}Id;
import ${CliPackage}.FrameworkExecution;
import ${ViewUtilPackage}.CheckProcessContentProvider;
import ${ViewUtilPackage}.CheckProcessLabelProvider;
import info.scce.mcam.framework.processes.CheckProcess;

import java.io.File;

import org.apache.commons.collections.keyvalue.DefaultKeyValue;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;

public class CheckViewInformation extends ${McamViewBasePackage}.CheckViewInformation {
	
	private CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> cp = null;
	
	public CheckViewInformation(File file, Resource resource) {
		super(file, resource);
	}
	
	@Override
	public void createCheckProcess() {
		${GraphModelName}Adapter model = FrameworkExecution
				.initApiAdapterFromResource(resource, file);

		cp = FrameworkExecution
				.createCheckPhase(model);
		cp.checkModel();
	}
	
	@Override
	public void createCheckViewTree(Composite parent) {
		treeViewer = new TreeViewer(parent, SWT.BORDER | SWT.V_SCROLL
				| SWT.H_SCROLL);
		treeViewer.setContentProvider(new CheckProcessContentProvider());
		treeViewer.setLabelProvider(new CheckProcessLabelProvider());
		treeViewer.setInput(cp);
		treeViewer.getTree().setLayout(new GridLayout(1, false));
		treeViewer.getTree().setLayoutData(
				new GridData(SWT.FILL, SWT.FILL, true, true));

		treeViewer.addSelectionChangedListener(new ISelectionChangedListener() {
			public void selectionChanged(SelectionChangedEvent event) {
				if (event.getSelection() instanceof IStructuredSelection) {
					IStructuredSelection selection = (IStructuredSelection) event
							.getSelection();
					if (selection.getFirstElement() instanceof DefaultKeyValue) {
						DefaultKeyValue pair = (DefaultKeyValue) selection.getFirstElement();
						cp.getModel().highlightElement(
								(${GraphModelName}Id) pair.getKey());
					}
					treeViewer.refresh();
				}
			}
		});
	}

	public CheckProcess<${GraphModelName}Id, ${GraphModelName}Adapter> getCp() {
		return cp;
	}

}

