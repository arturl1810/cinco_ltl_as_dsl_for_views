package de.jabc.cinco.meta.plugin.gratext.build;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil;
import org.eclipse.emf.codegen.util.CodeGenUtil;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionDelegate;

public class GenmodelGenerator implements IActionDelegate {

	private ISelection selection;
	private Display display;

	@Override
	public void run(IAction action) {
		display = Display.getCurrent();
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IFile) {
				IFile file = (IFile) ssel.getFirstElement();
				Job job = new Job("Generate Model Code") {
					@Override
					protected IStatus run(IProgressMonitor monitor) {
//						SubMonitor subMonitor = SubMonitor.convert(monitor, 100);
//						subMonitor.setWorkRemaining(95);
//						int totalWork = 1;
//						int workTick = 95/totalWork;
//						int worked = 1;
//						subMonitor.setTaskName("Backing up file " + (worked++) + "/" + totalWork + ": " + entry.getKey().getName());
//						subMonitor.worked(workTick);
						
						try {
							generateModelCode(file, monitor);
						} catch (IOException e) {
							e.printStackTrace();
						}
						if (monitor.isCanceled())
							return Status.CANCEL_STATUS;
						return Status.OK_STATUS;
					};
				};
				job.addJobChangeListener(new JobChangeAdapter() {
			        public void done(IJobChangeEvent event) {
			        if (event.getResult().isOK())
			        		showMessage("Model generation successful.");
			        else if (!event.getResult().equals(Status.CANCEL_STATUS))
			        		showErrorMessage("Some generations seem to have failed.");
			        }
			     });
			    job.setUser(true);
				job.schedule();
			}
		}
	}
	
	private void generateModelCode(IFile genModelFile, IProgressMonitor monitor) throws IOException {
		Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(genModelFile.getFullPath().toOSString(), true),true);
		res.load(null);
		res.getContents().stream()
			.filter(GenModel.class::isInstance)
			.map(GenModel.class::cast)
			.forEach(genModel -> {
				genModel.reconcile();
				
				// !!! Very important lines, do not delete !!!
				genModel.getUsedGenPackages().stream()
					.filter(pkg -> !pkg.getGenModel().equals(genModel))
					.forEach(genModel.getUsedGenPackages()::add);
				
				genModel.setCanGenerate(true);
				GenModelUtil.createGenerator(genModel).generate(genModel,
						GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, CodeGenUtil.EclipseUtil.createMonitor(monitor, 1));
			});
		
//		for (EObject content : res.getContents()) {	
//			if (content instanceof GenModel) {
//				final GenModel genModel = (GenModel) content;
//				genModel.reconcile();
//				for (GenPackage gm : genModel.getUsedGenPackages())
//					if (!gm.getGenModel().equals(genModel)) 
//						genModel.getUsedGenPackages().add(gm);
//				genModel.setCanGenerate(true);
//				GenModelUtil.createGenerator(genModel).generate(genModel,
//						GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, CodeGenUtil.EclipseUtil.createMonitor(monitor, 1));
//			}
//		}
	}
	
	private void showMessage(String msg) {
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Model Code Generator", display.getSystemImage(SWT.ICON_INFORMATION),
	            msg, MessageDialog.INFORMATION, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	private void showErrorMessage(String msg) {
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Model Code Generator", display.getSystemImage(SWT.ICON_ERROR),
	            msg, MessageDialog.ERROR, new String[] {"OK"}, 0
	        ).open()
		);
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}

}
