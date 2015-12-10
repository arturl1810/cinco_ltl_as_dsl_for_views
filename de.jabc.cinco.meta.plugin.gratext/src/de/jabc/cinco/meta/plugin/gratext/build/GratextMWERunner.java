package de.jabc.cinco.meta.plugin.gratext.build;

import static de.jabc.cinco.meta.plugin.gratext.util.GratextUtils.task;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationType;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil;
import org.eclipse.emf.codegen.util.CodeGenUtil;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Launcher;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionDelegate;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.services.IServiceLocator;

public class GratextMWERunner implements IActionDelegate {

	private ISelection selection;
	private Display display;

	private int worked = 1;
	
	@Override
	public void run(IAction action) {
		display = Display.getCurrent();
		
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IProject) {
//				generate((IProject) ssel.getFirstElement());
				launch();
			}
		}
	}
	
	private void generate(IProject project) {
		Job job = new Job("Generate Gratext Model") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				SubMonitor subMonitor = SubMonitor.convert(monitor, 100);
				
				List<IFile> files = getProjectFiles(project, "mwe2").stream()
						.filter(file -> file.getName().endsWith("Gratext.mwe2"))
						.collect(Collectors.toList());
				
				subMonitor.setWorkRemaining(95);
				int totalWork = files.size();
				int workTick = 95/totalWork;
				worked = 1;
				
				files.stream().forEach(file -> { try {
					subMonitor.setTaskName("Generating " + (worked++) + "/" + totalWork + ": " + file.getName());
					subMonitor.worked(workTick);
					runMWE(file);
				} catch (Exception e) {
					e.printStackTrace();
				}});
				
				if (monitor.isCanceled())
					return Status.CANCEL_STATUS;
				
				subMonitor.done();
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
	
	private void execute(String commandId) {
		IServiceLocator serviceLocator = PlatformUI.getWorkbench();
		ICommandService commandService = (ICommandService) serviceLocator.getService(ICommandService.class);
		try { 
		    Command command = commandService.getCommand(commandId);
		    // optional ExecutionEvent, default creates blank event
		    command.executeWithChecks(new ExecutionEvent());
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}
	
	private void launch() {
		ILaunchManager manager = DebugPlugin.getDefault().getLaunchManager();
		ILaunchConfigurationType type = manager.getLaunchConfigurationType("org.eclipse.emf.mwe2.launch.Mwe2LaunchConfigurationType");
//		for (ILaunchConfigurationType type : manager.getLaunchConfigurationTypes()) {
//			System.out.println("LaunchConfigurationType: " + type.getIdentifier());
//		}
		ILaunchConfiguration[] configurations;
		try {
			ILaunchConfigurationWorkingCopy cfg = null;
			configurations = manager.getLaunchConfigurations(type);
			for (ILaunchConfiguration config : configurations) {
				System.out.println("LaunchConfiguration: " + config.getName());
				if (config.getName().equals("Run Gratext MWE")) {
					cfg = config.getWorkingCopy();
					break;
				}
			}
			if (cfg == null)
				cfg = type.newInstance(null, "Run Gratext MWE");
			
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private void runMWE(IFile file) {
		task("MWE2 Workflow").run(() -> {
			String fileName = file.getFullPath().toOSString();
			System.out.println("MWE file: " + fileName);
			
			new Mwe2Launcher().run(new String[]{fileName});
		});
//		ISafeRunnable runnable = new ISafeRunnable() {
//			
//			private String fileName;
//			
//			@Override
//			public void handleException(Throwable e) {
//				System.out.println("Failed to run MWE2 workflow on " + fileName + ": " + e.getMessage());
//			}
//
//			@Override
//			public void run() throws Exception {
//				FileDescriptor file = getFileDescriptor(GratextMWETemplate.class);
//				fileName = file.resource().getFullPath().toOSString();
////				String path = file.resource().getFullPath().toOSString();
////				String path = file.resource().getLocation().toOSString();
//				System.out.println("MWE file: " + fileName);
////				project.getProjectRelativePath().append(new Path(file.getProjectRelativeDir()).append(file.))
////				Mwe2Launcher.main(new String[]{"src/info/scce/dime/data/gratext/DataGratext.mwe2"});
//				new Mwe2Launcher().run(new String[]{fileName});
//			}
//		};
//		SafeRunner.run(runnable);
	}
	
	
	
//	private void runMWE(IFile file) {
//		System.out.println("Run MWE2 workflow");
//		try {
//			Resource res = new ResourceSetImpl().getResource(
//					URI.createPlatformResourceURI(file.getFullPath().toOSString(), true), true);
//			res.load(null);
//			System.out.println(" > resource: " + res);
//			for (EObject content : res.getContents()) {
//				System.out.println("   > " + content);
//				if (content instanceof Module) {
//					new Mwe2Runner().run(((Module) content).getCanonicalName(), null);
//					break;
//				}
//			}
//		} catch(Exception e) {
//			e.printStackTrace();
//		}
//	}
	
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
	}
	
	private void showMessage(String msg) {
		display.syncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Gratext Model Generator", display.getSystemImage(SWT.ICON_INFORMATION),
	            msg, MessageDialog.INFORMATION, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	private void showErrorMessage(String msg) {
		display.syncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Gratext Model Generator", display.getSystemImage(SWT.ICON_ERROR),
	            msg, MessageDialog.ERROR, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	protected List<IFile> getWorkspaceFiles(String fileExtension) {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), fileExtension, true);
	}
	
	protected List<IFile> getProjectFiles(IProject project, String fileExtension) {
		return getFiles(project, fileExtension, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
	    List<IFile> files = new ArrayList<>();
	    IResource[] members = null;
	    try {
	    	members = container.members();
	    } catch(CoreException e) {
	    	e.printStackTrace();
	    }
	    if (members != null)
			Arrays.stream(members).forEach(mbr -> {
			   if (recurse && mbr instanceof IContainer)
				   files.addAll(getFiles((IContainer) mbr, fileExtension, recurse));
			   else if (mbr instanceof IFile && !mbr.isDerived()) {
				   IFile file = (IFile) mbr;
				   if (fileExtension == null || fileExtension.equals(file.getFileExtension()))
				       files.add(file);
			   }
		   });
		return files;
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}

}
