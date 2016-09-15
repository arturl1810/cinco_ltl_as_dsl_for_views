package de.jabc.cinco.meta.plugin.generator.runtime.handler;
import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.resp;
import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;
import graphmodel.GraphModel;

import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;

import de.jabc.cinco.meta.core.utils.job.CompoundJob;
import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;
import de.jabc.cinco.meta.plugin.generator.runtime.registry.GeneratorDiscription;
import de.jabc.cinco.meta.plugin.generator.runtime.registry.GraphModelGeneratorRegistry;

/**
 * Handler implementation for the code generation command.
 * 
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class GraphModelCodeGenerationHandler extends AbstractHandler {
	
	private IGenerator<GraphModel> generator;
	private GraphModel graphModel;
	private String fileName;
	private IProject project;
	private IPath outlet;
	
	public GraphModelCodeGenerationHandler() { }
	
	
	/**
	 * the command has been executed, so extract the needed information
	 * from the application context.
	 */
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		CompoundJob job = job("Code Generation");
		
		job.consume(100, "Initializing...")
			.task("Retrieve graph model", () -> init(event));
		
		job.schedule();
		
		try {
			job.join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		IStatus result = job.getResult();
		if (Status.OK != result.getSeverity()) {
			return null;
		}
		
		job = job("Code Generation")
				.label("Generating for model " + fileName + " ...");
		
		generator.collectTasks(graphModel, outlet, job);
		
		job.consume(5, "Refreshing workspace...")
		   .task("Refreshing workspace...", this::refreshProject)
//		   .onCanceledShowMessage("Code generation canceled.")
		   .onFinishedShowMessage("Code generation successful.")
		   .schedule();
		
		return null;
		
//		
//		try {
//			
//
//			final URI uri = resp(activeEditor).getResource().getURI();
//
//			IProgressService ps = window.getWorkbench().getProgressService();
//			ps.run(true, true, new IRunnableWithProgress() {
//
//				@Override
//				public void run(IProgressMonitor monitor)
//						throws InvocationTargetException, InterruptedException {
//
//					try {
//						GraphModel graphModel = resp(activeEditor).getGraphModel();
//
//						if (graphModel != null) {
//							String graphModelClassName = 
//									graphModel.getClass().getName().replace("Impl", "").replace(".impl", "");
//							List<GeneratorDiscription<GraphModel>> generatorDiscriptions =
//									GraphModelGeneratorRegistry.INSTANCE.getAllGenerators(graphModelClassName);
//							if (generatorDiscriptions != null) {
//								for (GeneratorDiscription<GraphModel> generatorDiscription : generatorDiscriptions) {
//									IGenerator<GraphModel> generator = generatorDiscription.getGenerator();
//									
//									IProject project = resp(activeEditor).getProject();
////									IFolder outletFolder = resp(project).createFolder(generatorDiscription.getOutlet());
//									IPath outlet = project.getLocation().append(
//											generatorDiscription.getOutlet());
//									
//									if (!outlet.toFile().exists()) {
//										outlet.toFile().mkdirs();
//									} else if (!outlet.toFile().isDirectory()) {
//										throw new RuntimeException(
//												"Outlet /src-gen/ already exists, but is no directory.");
//									}
//									
//									
//									
//									generator.generate(graphModel, outlet, monitor);
//									project.refreshLocal(IProject.DEPTH_INFINITE, monitor);
//								}
//								
//								
////								new Thread(new Runnable() {
////									public void run() {
////										Display.getDefault().asyncExec(
////												new Runnable() {
////													public void run() {
////														MessageDialog
////																.openInformation(
////																		HandlerUtil
////																				.getActiveShell(event),
////																		"Code generation succeeded",
////																		"The code for model\n\""
////																				+ uri.lastSegment()
////																				+ "\"\nwas succesfully generated.");
////													}
////												});
////									}
////								}).start();
//							}
//						}
//
//					} catch (Exception e) {
//						final Status status = new Status(IStatus.ERROR, uri
//								.toString(), e.getMessage(), e);
//						new Thread(new Runnable() {
//							public void run() {
//								Display.getDefault().asyncExec(new Runnable() {
//									public void run() {
//										ErrorDialog.openError(
//												HandlerUtil
//														.getActiveShell(event),
//												"Error during code generation",
//												"An error occured during generation",
//												status);
//									}
//								});
//							}
//						}).start();
//						e.printStackTrace();
//					}
//				}
//
//			});
//		} catch (InvocationTargetException | InterruptedException e) {
//			e.printStackTrace();
//		} catch (ClassCastException e) {
//
//		}
//		return null;
	}
	
	private void init(ExecutionEvent event) {
		IEditorPart activeEditor = null;
		try {
			IWorkbenchWindow window = HandlerUtil.getActiveWorkbenchWindowChecked(event);
			activeEditor = window.getActivePage().getActiveEditor();
		} catch (Exception e) {
			throw new RuntimeException("Failed to retrieve active editor.", e);
		}
		try {
			fileName = resp(activeEditor).getResource().getURI().lastSegment();
			graphModel = resp(activeEditor).getGraphModel();
		} catch (Exception e) {
			throw new RuntimeException("Failed to retrieve graph model for editor: " + activeEditor, e);
		}
		try {
			String graphModelClassName = 
					graphModel.getClass().getName().replace("Impl", "").replace(".impl", "");
			List<GeneratorDiscription<GraphModel>> generatorDescriptions =
					GraphModelGeneratorRegistry.INSTANCE.getAllGenerators(graphModelClassName);
			
			if (generatorDescriptions == null) {
				throw new RuntimeException(
						"No generator found for model class: " + graphModelClassName);
			} else for (GeneratorDiscription<GraphModel> generatorDiscription : generatorDescriptions) {
				generator = generatorDiscription.getGenerator();
				System.err.println("### generator: " + generator);
				if (generator == null) {
					throw new RuntimeException(
							"No generator found for model class: " + graphModelClassName);
				}
				project = resp(activeEditor).getProject();
//				IFolder outletFolder = resp(project).createFolder(generatorDiscription.getOutlet());
				outlet = project.getLocation().append(generatorDiscription.getOutlet());
				if (!outlet.toFile().exists()) {
					outlet.toFile().mkdirs();
				} else if (!outlet.toFile().isDirectory()) {
					throw new RuntimeException("Outlet exists, but is no directory: " + outlet);
				}
			}
		} catch(Exception e) {
			throw new RuntimeException("Failed to start generator due to an unexpected error.", e);
		}
	}
	
	private void refreshProject() {
		try {
			project.refreshLocal(IProject.DEPTH_INFINITE, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
}