package de.jabc.cinco.meta.plugin.gratext.build;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IProcess;

import de.jabc.cinco.meta.core.utils.job.ReiteratingJob;


public class GratextLanguageBuild extends ReiteratingJob {

	private IProject project;
	private IFolder modelFolder;
	private IFile mwe2;
	private IFile xtext;
	private IProgressMonitor monitor;
	private IStatus jobStatus;
	private boolean failed;
	
	public GratextLanguageBuild(IProject project) {
		super("Building Gratext: " + project.getName());
		this.project = project;
	}

	@Override
	protected void prepare() {
		monitor = getMonitor();
		findModelFolder();
		refreshProjects();
		findMwe2();
		runMwe2();
	}
	
	@Override
	protected void repeat() {
		if (jobStatus != null)
			quit(jobStatus);
	}
	
	@Override
	protected void afterwork() {
		if (jobStatus.isOK())  {
			deleteSources();
			buildProjects();
		} else refreshProjects();
	}
	
	private void findModelFolder() {
		if (!failed) try {
			monitor.setTaskName("Retrieve .genmodel: " + project.getName());
			modelFolder = project.getFolder("model");
		} catch(Exception e) {
			fail("Failed to retrieve .genmodel file.", e);
			return;
		}
	}
	
	private void findMwe2() {
		if (!failed) try {
			
			xtext = getProjectFiles("xtext").stream()
				.filter(file -> file.getName().endsWith("Gratext.xtext"))
				.collect(Collectors.toList())
				.get(0);
			
			mwe2 = getProjectFiles("mwe2").stream()
				.filter(file -> file.getName().endsWith("Gratext.mwe2"))
				.collect(Collectors.toList())
				.get(0);
			
		} catch(Exception e) {
			fail("Genmodel job fine, but failed to retrieve .mwe2 file.", e);
			return;
		}
	}
	
	private void runMwe2() {
		if (!failed) try {
			monitor.setTaskName("Mwe2 job: " + mwe2.getName());
			GratextMwe2Job job = new GratextMwe2Job(project, mwe2) {

				boolean success;
				
				@Override
				public void onTerminated(IProcess process) {
					try {
						success = (process.getExitValue() == 0);
					} catch (DebugException e) {
						e.printStackTrace();
					}
				}

				@Override
				public void onQuit() {
					jobStatus = success
						? Status.OK_STATUS
						: new Status(Status.ERROR, getName(), "Mwe2 workflow failed.");
				}
			};
			job.start();
		} catch(Exception e) {
			fail("Mwe2 workflow failed.",  e);
			return;
		}
	}
	
	private void deleteSources() {
		if (!failed) try {
			monitor.setTaskName("Cleaning up " + mwe2.getName());
			xtext.delete(true, null);
			mwe2.delete(true, null);
			modelFolder.delete(true, null);
		} catch(Exception e) {
			fail("Failed to delete model sources (mwe2, xtext, model folder)", e);
			return;
		}
	}
	
	private void refreshProjects() {
		refreshProject("");
		refreshProject(".ide");
		refreshProject(".ui");
	}
	
	private void refreshProject(String suffix) {
		if (!failed) try {
			String projectName = this.project.getName() + suffix;
			IProject project = getProject(projectName);
			if (project != null) {
				monitor.setTaskName("Refreshing " + projectName);
				project.refreshLocal(IProject.DEPTH_INFINITE, null);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private void buildProjects() {
		buildProject("");
		buildProject(".ide");
		buildProject(".ui");
	}
	
	public void buildProject(String suffix) {
		if (!failed) try {
			String projectName = this.project.getName() + suffix;
			IProject project = getProject(projectName);
			if (project != null) {
				monitor.setTaskName("Refreshing " + projectName);
				project.refreshLocal(IProject.DEPTH_INFINITE, null);
				monitor.setTaskName("Building " + projectName);
				project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private IProject getProject(String name) {
		return ResourcesPlugin.getWorkspace().getRoot().getProject(name);
	}
	
	private List<IFile> getProjectFiles(String fileExtension) {
		return getFiles(project, fileExtension, true);
	}
	
	private List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
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
	protected void fail(String msg, Exception e) {
		failed = true;
		super.fail(msg, e);
	}
}
