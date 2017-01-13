package de.jabc.cinco.meta.core.mgl.ui.handlers;



import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
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

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI;
import mgl.GraphModel;

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
	public Object execute(ExecutionEvent event) throws ExecutionException{
		this.event = event;
		
			
			 IProgressService ps = HandlerUtil.getActiveWorkbenchWindowChecked(event).getWorkbench().getProgressService();
			 try {
				callGenerator();
			} catch (Exception e) {
				throw new ExecutionException("Exception in MGL 2 Ecore Transformation", e);
			}
		
		
		return null;
	}

	private void callGenerator() {
		GraphModel model = MGLSelectionListener.INSTANCE.getCurrentMGLGraphModel();
		IProject mglProject = ResourceEAPI.getProject(model.eResource());
		
		
		
		try {
			//monitor.subTask("Loading Resource");
			
			EclipseResourceFileSystemAccess2 access = fileAccessProvider.get();
			access.setProject(mglProject);
			access.setMonitor(null);
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
			
			generator.doGenerate(model.eResource(), access);

		} catch (Exception e) {
			throw new RuntimeException(e.getMessage(), e);
		}
		try {
			mglProject.refreshLocal(0, null);
		} catch (CoreException e) {
			e.printStackTrace();
			
		}
		
	}

}
