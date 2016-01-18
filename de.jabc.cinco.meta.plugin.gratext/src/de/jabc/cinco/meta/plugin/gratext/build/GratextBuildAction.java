package de.jabc.cinco.meta.plugin.gratext.build;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceDescription;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionDelegate;

import de.jabc.cinco.meta.core.utils.job.JobFactory;


public class GratextBuildAction implements IActionDelegate {

	private ISelection selection;
	private Display display;
	private List<IProject> projects;
	private boolean autoBuild;
	
	@Override
	public void run(IAction action) {
		JobFactory.job("Gratext Builder")
		  .cancelOnFail(false)
		  
		  .consume(5, "Initializing...")
		    .task(this::init)
		    .cancelIf(() -> projects.isEmpty(),
	    		"No Gratext model files found.\n"
    			+ "Gratext build finished (in a fairly trivial way).")
			.task(this::disableAutoBuild)
		  
		  .consumeConcurrent(100, "Running Gratext builds...")
		    .taskForEach(() -> projects.stream(),
		    	this::spawnJob, IProject::getName)
		  
		  .onFinished(() -> showMessage("Gratext build finished."))
		  .onDone(this::resetAutoBuild)
		  .schedule();
	}
	
	private void init() {
		projects = Arrays.stream(getProjects())
				.filter(project -> project.getName().endsWith("gratext"))
				.filter(project -> containsGratextMWE(project))
				.collect(Collectors.toList());
	}
	
	private void spawnJob(IProject project) {
		GratextBuild job = new GratextBuild(project);
		job.schedule();
		try {
			job.join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
	
	private IProject[] getProjects() {
		return ResourcesPlugin.getWorkspace().getRoot().getProjects();
	}
	
	private boolean containsGratextMWE(IProject project) {
		return !getProjectFiles(project, "mwe2").stream()
			.filter(file -> file.getName().endsWith("Gratext.mwe2"))
			.collect(Collectors.toList())
			.isEmpty();
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
	
	private void showMessage(String msg) {
		if (display == null)
			display = Display.getDefault();
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Gratext Builder", display.getSystemImage(SWT.ICON_INFORMATION),
	            msg, MessageDialog.INFORMATION, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	private void setAutoBuild(boolean enable) throws CoreException {
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IWorkspaceDescription desc = workspace.getDescription();
		autoBuild = desc.isAutoBuilding();
		if (autoBuild != enable) {
			desc.setAutoBuilding(enable);
			workspace.setDescription(desc);
		}
	}
	
	private boolean isAutoBuild() {
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IWorkspaceDescription desc = workspace.getDescription();
		return desc.isAutoBuilding();
	}
	
	private void disableAutoBuild() {
		try {
			setAutoBuild(false);
		} catch (Exception e) {
			if (isAutoBuild()) {
				System.out.println("[Gratext] WARN: Failed to deactivate \"Build Automatically\".");
				e.printStackTrace();
			}
		}
	}
	
	private void resetAutoBuild() {
		try {
			setAutoBuild(autoBuild);
		} catch (Exception e) {
			if (!autoBuild != isAutoBuild()) {
				System.out.println("[Gratext] WARN: Failed to reset state for \"Build Automatically\". "
						+ "Should be " + autoBuild);
				e.printStackTrace();
			}
		}
	}
	
	public void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}

}
