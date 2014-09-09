package de.jabc.cinco.meta.core.mgl.ui.handlers;



import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2.IFileCallback;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class MGLGenerationHandler extends AbstractHandler {
    @Inject
    private IGenerator generator;
 
    @Inject
    private Provider<EclipseResourceFileSystemAccess2> fileAccessProvider;
     
    @Inject
    IResourceDescriptions resourceDescriptions;
     
    @Inject
    IResourceSetProvider resourceSetProvider;

	private ExecutionEvent event;
	/**
	 * The constructor.
	 */
	public MGLGenerationHandler() {
	}

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	public Object execute(ExecutionEvent event) throws ExecutionException {
		this.event = event;
		try {
			
			 IProgressService ps = HandlerUtil.getActiveWorkbenchWindowChecked(event).getWorkbench().getProgressService();
			 ps.run(false, true, new MGLGenerator());
		} catch (Exception e1) {
			
			StringBuilder builder = new StringBuilder();
			Throwable e = e1.getCause();
			StackTraceElement[] trace = e.getStackTrace();
			
			builder.append(e.getLocalizedMessage()+":\n");
			for(int i=0;i<Math.min(5, trace.length);i++){
				builder.append(trace[i].toString());
			}
			Object trigger = event.getTrigger();
			String canonicalName = "";
			if(trigger!=null)
				canonicalName = trigger.getClass().getCanonicalName();
			else
				canonicalName = this.getClass().getCanonicalName();
			
			IStatus status = new Status(Status.ERROR,canonicalName,builder.toString());
			ErrorDialog.openError(HandlerUtil.getActiveShell(event), "Error in Cinco Product Generation", "An error occured: "+e.getMessage(), status);
			
			e1.printStackTrace();
			
			
		}
		
		return null;
	}

	private class MGLGenerator implements IRunnableWithProgress{

		@Override
		public void run(IProgressMonitor monitor)
				throws InvocationTargetException, InterruptedException {
			ISelection selection = HandlerUtil.getActiveMenuSelection(event);
			if(selection instanceof StructuredSelection){
				StructuredSelection structuredSelection = (StructuredSelection)selection;
				IFile file = null;
				if(structuredSelection.getFirstElement() instanceof IFile){
					file = (IFile)structuredSelection.getFirstElement();
				
				ResourceSet rSet = resourceSetProvider.get(file.getProject());
				
				Resource res = rSet.createResource(URI.createPlatformResourceURI(file.getFullPath().toOSString(), true));
				System.err.println("File exists: " + file.getFullPath().toOSString());
				monitor.worked(0);
				
				try {
					monitor.subTask("Loading Resource");
					res.load(null);
					EclipseResourceFileSystemAccess2 access = fileAccessProvider.get();
					access.setProject(file.getProject());
					access.setMonitor(monitor);
					OutputConfiguration defaultOutput = new OutputConfiguration("DEFAULT_OUTPUT");
				    defaultOutput.setOutputDirectory("./src-gen");
				    defaultOutput.setCreateOutputDirectory(true);
				    defaultOutput.setOverrideExistingResources(true);
				    defaultOutput.setCleanUpDerivedResources(true);
				    defaultOutput.setSetDerivedProperty(true);
				    defaultOutput.setCanClearOutputDirectory(true);
				    
					access.getOutputConfigurations().put("DEFAULT_OUTPUT", defaultOutput);
					access.setPostProcessor(new IFileCallback() {
						
						@Override
						public boolean beforeFileDeletion(IFile file) {
							return false;
						}
						
						@Override
						public void afterFileUpdate(IFile file) {}
						
						@Override
						public void afterFileCreation(IFile file) {}
					});
					
					monitor.worked(0);
					monitor.subTask("Generating Ecore And GenModel File");
					generator.doGenerate(res, access);
					monitor.worked(0);

				} catch (Exception e) {
					throw new InvocationTargetException(e, e.getMessage());
				}
				try {
					file.getProject().refreshLocal(0, monitor);
				} catch (CoreException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			}
			
		}
		
	}
}
