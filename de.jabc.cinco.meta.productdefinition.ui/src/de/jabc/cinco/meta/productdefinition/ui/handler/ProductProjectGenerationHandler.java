package de.jabc.cinco.meta.productdefinition.ui.handler;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.OutputConfiguration;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.productdefinition.generator.CPDGenerator;


public class ProductProjectGenerationHandler extends AbstractHandler {
	
    private IGenerator generator;
    
    //@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {	
		 IProgressService ps = HandlerUtil.getActiveWorkbenchWindowChecked(event).getWorkbench().getProgressService();
		 try {
			ps.run(false, true, new ProductProjectGenerator(event));
		} catch (Exception e) {
			throw new ExecutionException("Exception while Generating Product Project", e);
		}
		return null;
	}
	
	
	private class ProductProjectGenerator implements IRunnableWithProgress{

		private ExecutionEvent event;

		public ProductProjectGenerator(ExecutionEvent event) {
			this.event = event;
		}

		//@Override
		public void run(IProgressMonitor monitor)
				throws InvocationTargetException, InterruptedException {
			//monitor.subTask("Generating Cinco Product.");
			if(!monitor.isCanceled()){
				IFile selectedFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
				if(selectedFile.getFileExtension().equals("cpd")){
					IProject project = selectedFile.getProject();
					//ResourceSet rSet =   resourceSetProvider.get(project);
					URI createPlatformResourceURI = URI.createPlatformResourceURI(selectedFile.getFullPath().toOSString(), true);
					//Resource res = rSet.createResource(createPlatformResourceURI);
					Resource res = Resource.Factory.Registry.INSTANCE.getFactory(createPlatformResourceURI, "cpd").createResource(createPlatformResourceURI);
					try {
						//monitor.subTask("Loading Resource");
						res.load(null);
						EclipseResourceFileSystemAccess2 access =  new EclipseResourceFileSystemAccess2();//fileAccessProvider.get();
						access.setProject(project);
						access.setMonitor(monitor);
						OutputConfiguration defaultOutput = new OutputConfiguration("DEFAULT_OUTPUT");
					    defaultOutput.setOutputDirectory("./src-gen");
					    defaultOutput.setCreateOutputDirectory(true);
					    defaultOutput.setOverrideExistingResources(true);
					    defaultOutput.setCleanUpDerivedResources(true);
					    defaultOutput.setSetDerivedProperty(true);
					    defaultOutput.setCanClearOutputDirectory(true);
					    
						access.getOutputConfigurations().put("DEFAULT_OUTPUT", defaultOutput);
//						access.setPostProcessor(new IFileCallback() {
//							
//							@Override
//							public boolean beforeFileDeletion(IFile file) {
//								return false;
//							}
//							
//							@Override
//							public void afterFileUpdate(IFile file) {}
//							
//							@Override
//							public void afterFileCreation(IFile file) {}
//						});
						generator = new CPDGenerator();
						generator.doGenerate(res, access);
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					
				}
				
			}
			
		}
		
	}
}
