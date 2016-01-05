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
			callGenerator();
		} catch (Exception e) {
			throw new RuntimeException("Exception while Generating Product Project", e);
		}
		return null;
	}
	
	
	private void callGenerator() {
			IFile selectedFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
			if(selectedFile.getFileExtension().equals("cpd")){
				IProject project = selectedFile.getProject();
				URI createPlatformResourceURI = URI.createPlatformResourceURI(selectedFile.getFullPath().toOSString(), true);
				Resource res = Resource.Factory.Registry.INSTANCE.getFactory(createPlatformResourceURI, "cpd").createResource(createPlatformResourceURI);
				try {
					res.load(null);
					EclipseResourceFileSystemAccess2 access =  new EclipseResourceFileSystemAccess2();
					access.setProject(project);
					access.setMonitor(null);
					OutputConfiguration defaultOutput = new OutputConfiguration("DEFAULT_OUTPUT");
				    defaultOutput.setOutputDirectory("./src-gen");
				    defaultOutput.setCreateOutputDirectory(true);
				    defaultOutput.setOverrideExistingResources(true);
				    defaultOutput.setCleanUpDerivedResources(true);
				    defaultOutput.setSetDerivedProperty(true);
				    defaultOutput.setCanClearOutputDirectory(true);
				    
					access.getOutputConfigurations().put("DEFAULT_OUTPUT", defaultOutput);
					generator = new CPDGenerator();
					generator.doGenerate(res, access);
				} catch (IOException e) {
					throw new RuntimeException(e);
				}
				
			}
			
		
		
	}



}
