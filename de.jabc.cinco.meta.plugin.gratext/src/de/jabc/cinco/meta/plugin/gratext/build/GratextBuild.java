package de.jabc.cinco.meta.plugin.gratext.build;

import java.io.IOException;
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
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IProcess;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.codegen.ecore.genmodel.util.GenModelUtil;
import org.eclipse.emf.codegen.util.CodeGenUtil;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

import de.jabc.cinco.meta.plugin.gratext.util.ReiteratingJob;

public class GratextBuild extends ReiteratingJob {

	private IProject project;
	private IFile genmodel;
	private IFile mwe2;
	private IFile xtext;
//	private IProgressMonitor monitor;
	private IStatus jobStatus;
	
	public GratextBuild(IProject project) {
		super("Building Gratext: " + project.getName());
		this.project = project;
	}

	@Override
	protected void prepare() {
//		SubMonitor mainMonitor = getMonitor();
//		monitor = SubMonitor.convert(mainMonitor.newChild(2), 100);
//		monitor.setTaskName("Building gratext: " + project.getName());
		
		try {
			findGenmodel();
		} catch(Exception e) {
			fail("Failed to retrieve .genmodel file.", e);
			return;
		}
		
//		mainMonitor.setWorkRemaining(98);
//		monitor = SubMonitor.convert(mainMonitor.newChild(36), 100);
		
		try {
			runGenmodel();
		} catch(Exception e) {
			fail("Model code generation failed.", e);
			return;
		}
		
//		mainMonitor.setWorkRemaining(72);
//		monitor = SubMonitor.convert(mainMonitor.newChild(2), 100);
		
		try {
			findMwe2();
		} catch(Exception e) {
			fail("Genmodel job fine, but failed to retrieve .mwe2 file.", e);
			return;
		}
		
//		mainMonitor.setWorkRemaining(70);
//		monitor = SubMonitor.convert(mainMonitor.newChild(66), 100);
		
		try {
			runMwe2();
		} catch(Exception e) {
			fail("Genmodel job fine, but Mwe2 workflow failed.",  e);
			return;
		}
	}
	
	@Override
	protected void repeat() {
		if (jobStatus != null) {
			System.out.println("[Gratext] Job Status: " + jobStatus);
			setStatus(jobStatus);
			quit();
		}
	}
	
	@Override
	protected void afterwork() {
//		SubMonitor mainMonitor = getMonitor();
		
		System.out.println("[Gratext] Status " + getStatus() +  "(" + getStatus().isOK() + ") " + project.getName());
		if (getStatus().getSeverity() != Status.ERROR)  {
//			mainMonitor.setWorkRemaining(4);
//			monitor = SubMonitor.convert(mainMonitor.newChild(2), 100);
			
			try {
				deleteSources();
			} catch(Exception e) {
				fail("Build process fine, but failed to delete .genmodel and/or .xtext file.", e);
				return;
			}
		}
		
//		mainMonitor.setWorkRemaining(2);
//		monitor = SubMonitor.convert(mainMonitor.newChild(2), 100);
		
		try {
			triggerRefresh();
		} catch(Exception e) {
			fail("Build process fine, but failed to trigger refresh on project.", e);
			return;
		}
	}
	
	private void findGenmodel() {
		genmodel = getProjectFiles("genmodel").stream()
			.filter(file -> file.getName().endsWith("Gratext.genmodel"))
			.collect(Collectors.toList())
			.get(0);
	}
	
	private void findMwe2() {
		xtext = getProjectFiles("xtext").stream()
				.filter(file -> file.getName().endsWith("Gratext.xtext"))
				.collect(Collectors.toList())
				.get(0);
		mwe2 = getProjectFiles("mwe2").stream()
			.filter(file -> file.getName().endsWith("Gratext.mwe2"))
			.collect(Collectors.toList())
			.get(0);
	}
	
	private void runGenmodel() throws IOException {
//		monitor.setTaskName("Running Genmodel job: " + genmodel.getName());
		Resource res = new ResourceSetImpl().getResource(
				URI.createPlatformResourceURI(genmodel.getFullPath().toOSString(), true),true);
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
//						GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, CodeGenUtil.EclipseUtil.createMonitor(monitor, 100));
						GenBaseGeneratorAdapter.MODEL_PROJECT_TYPE, CodeGenUtil.EclipseUtil.createMonitor(new NullProgressMonitor(), 100));
			});
	}
	
	private void runMwe2() {
//		monitor.setTaskName("Running Mwe2 job: " + mwe2.getName());
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
				System.out.println("[Gratext] OnQuit - success: " + success);
				jobStatus = success
					? Status.OK_STATUS
					: new Status(Status.ERROR, getName(), "Mwe2 workflow failed.");
				System.out.println("[Gratext] OnQuit - set status: " + jobStatus);
			}
		};
		job.start();
	}
	
	private void deleteSources() throws CoreException {
		System.out.println("[Gratext] Deleting sources: " + project.getName());
		xtext.delete(true, null);
		mwe2.delete(true, null);
		
	}
	
	private void triggerRefresh() {
		try {
//			project.refreshLocal(IResource.DEPTH_INFINITE, monitor);
//			getProject(project.getName() + ".ui").refreshLocal(IResource.DEPTH_INFINITE, monitor);
			project.refreshLocal(IResource.DEPTH_INFINITE, null);
			getProject(project.getName() + ".ui").refreshLocal(IResource.DEPTH_INFINITE, null);
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
}
