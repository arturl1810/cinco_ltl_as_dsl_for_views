package de.jabc.cinco.meta.plugin.gratext.build;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;

public class GratextBuilder extends Job {

	private List<GratextBuild> jobs;
	private List<GratextBuild> done;
	private List<GratextBuild> failed;
	private IProgressMonitor jobGroup;
	private Display display;
	private SubMonitor monitor;
	
    public GratextBuilder() {
        super("Building Gratext");
    }

	@Override
	protected IStatus run(IProgressMonitor mainMonitor) {
		monitor = SubMonitor.convert(mainMonitor, 100);
		monitor.beginTask("Retrieving model files...", 5);
		
		display = Display.getCurrent();
		jobs = new ArrayList<>();
		done = new ArrayList<>();
		failed = new ArrayList<>();
		
		List<IProject> projects = getGratextProjects();
		
		if (projects.isEmpty()) {
			showMessage("No Gratext model files found.\n"
					+ "Gratext build finished (in a fairly trivial way).");
			monitor.done();
			return Status.OK_STATUS;
		}
		
		monitor.beginTask("Spawning build jobs...", 5);
		
		jobGroup = Job.getJobManager().createProgressGroup();
		jobGroup.beginTask("Running build jobs...", 1000);
		projects.forEach(project -> spawnJob(project, 1000 / projects.size()));
		
		jobs.stream().forEach(job -> { try {
			job.join();
			monitor.beginTask("Completed build jobs: " + done.size() + "/" + jobs.size(), 90 / projects.size());
		} catch(InterruptedException e) {}});
		
		jobGroup.done();
		monitor.done();
		
		if (failed.isEmpty()) {
			showMessage("Gratext build finished.");
			return Status.OK_STATUS;
		}
		return Status.OK_STATUS;
	}
	
	private void spawnJob(IProject project, int ticks) {
		GratextBuild job = new GratextBuild(project);
		job.addJobChangeListener(new JobChangeAdapter() {
	        public void done(IJobChangeEvent event) {
	        	done.add(job);
		        if (!event.getResult().isOK() && !event.getResult().equals(Status.CANCEL_STATUS))
		        	failed.add(job);
		        }
	     	});
	    job.setProgressGroup(jobGroup, ticks);
	    jobs.add(job);
		job.schedule();
	}
	
	private List<IProject> getGratextProjects() {
		return Arrays.stream(getProjects())
				.filter(project -> project.getName().endsWith("gratext"))
				.filter(project -> containsGratextMWE(project))
				.collect(Collectors.toList());
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
}
