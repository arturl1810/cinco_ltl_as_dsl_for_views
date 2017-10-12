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
		findGenmodel();
//		runGenmodel();
//		buildProject();
		triggerRefresh();
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
			triggerRefresh();
			buildProject();
			buildUIProject();
		} else triggerRefresh();
	}
	
	private void findGenmodel() {
		if (!failed) try {
			monitor.setTaskName("Retrieve .genmodel: " + project.getName());
//			genmodel = getProjectFiles("genmodel").stream()
//				.filter(file -> file.getName().endsWith("Gratext.genmodel"))
//				.collect(Collectors.toList())
//				.get(0);
			modelFolder = project.getFolder("model");
		} catch(Exception e) {
			fail("Failed to retrieve .genmodel file.", e);
			return;
		}
	}
	
	private void findMwe2() {
		if (!failed) try {
//			xtext = WorkspaceUtil.resp(project.getFolder("src"))
//				.getFiles(file -> file.getName().endsWith("Gratext.xtext"))
//				.get(0);
					
					
			xtext = getProjectFiles("xtext").stream()
				.filter(file -> file.getName().endsWith("Gratext.xtext"))
				.collect(Collectors.toList())
				.get(0);
			
//			mwe2 = WorkspaceUtil.resp(project.getFolder("src"))
//				.getFiles(file -> file.getName().endsWith("Gratext.mwe2"))
//				.get(0);
			
			mwe2 = getProjectFiles("mwe2").stream()
				.filter(file -> file.getName().endsWith("Gratext.mwe2"))
				.collect(Collectors.toList())
				.get(0);
		} catch(Exception e) {
			fail("Genmodel job fine, but failed to retrieve .mwe2 file.", e);
			return;
		}
	}
	
//	private void runGenmodel() {
//		if (!failed) try {
//			monitor.setTaskName("Genmodel job: " + project.getName());
//			Resource res = new ResourceSetImpl().getResource(
//					URI.createPlatformResourceURI(genmodel.getFullPath().toString(), true),true);
//			res.load(null);
//			res.getContents().stream()
//				.filter(GenModel.class::isInstance)
//				.map(GenModel.class::cast)
//				.forEach(genModel -> {
//					genModel.reconcile();
//					
//					// !!! Very important lines, do not delete !!!
//					genModel.getUsedGenPackages().stream()
//						.filter(pkg -> !pkg.getGenModel().equals(genModel))
//						.forEach(genModel.getUsedGenPackages()::add);
//					
//					genModel.setCanGenerate(true);
//					GenModelUtil.createGenerator(genModel).generate(genModel,
//						GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE,
//						CodeGenUtil.EclipseUtil.createMonitor(new NullProgressMonitor(), 100));
//				});
//		} catch(Exception e) {
//			fail("Model code generation failed.", e);
//			return;
//		}
//	}
	
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
	
	private void triggerRefresh() {
		if (!failed) try {
			project.refreshLocal(IResource.DEPTH_INFINITE, null);
			getProject(project.getName() + ".ui").refreshLocal(IResource.DEPTH_INFINITE, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	public void buildProject() {
		if (!failed) try {
			monitor.setTaskName("Building " + project.getName());
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	public void buildUIProject() {
		if (!failed) try {
			String projectName = this.project.getName() + ".ui";
			IProject project = getProject(projectName);
			if (project != null) {
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
