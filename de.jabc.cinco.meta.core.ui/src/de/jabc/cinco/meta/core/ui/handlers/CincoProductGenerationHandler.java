package de.jabc.cinco.meta.core.ui.handlers;



import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.HandlerUtil;

import ProductDefinition.CincoProduct;
import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.GeneratorHelper;


/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class CincoProductGenerationHandler extends AbstractHandler {
	
	/**
	 * The constructor.
	 */
	public CincoProductGenerationHandler() {
	}
	ICommandService commandService;

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	synchronized public Object execute(ExecutionEvent event) throws ExecutionException {
		try{
			commandService = (ICommandService)PlatformUI.getWorkbench().getService(ICommandService.class);
			StructuredSelection selection = (StructuredSelection)HandlerUtil.getActiveMenuSelection(event);
			if(selection.getFirstElement() instanceof IFile){
				IFile mglModelFile = null;
				IFile cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
				CincoProduct cpd = loadCPD(cpdFile);
				BundleRegistry.resetRegistry();
				deleteGeneratedResources(cpdFile.getProject());
				for(String mglPath: cpd.getMgls()){
					mglModelFile = cpdFile.getProject().getFile(mglPath);
					MGLSelectionListener.INSTANCE.putMGLFile(mglModelFile);
					
					System.out.println("Generating Ecore/GenModel from MGL...");
					Command mglGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
					mglGeneratorCommand.executeWithChecks(event);
					
					System.out.println("Generating Model Code from GenModel...");
					
					
					System.out.println("Generating Graphiti Editor...");
					Command graphitiEditorGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
					graphitiEditorGeneratorCommand.executeWithChecks(event);
	//				IProject apiProject = ResourcesPlugin.getWorkspace().getRoot().getProject(mglModelFile.getProject().getName().concat(".graphiti.api"));
					
					GeneratorHelper.generateGenModelCode(mglModelFile);
					IProject apiProject = mglModelFile.getProject();
					if (apiProject.exists())
						GeneratorHelper.generateGenModelCode(apiProject, "C"+mglModelFile.getName().split("\\.")[0]);
					
					
					System.out.println("Generating jABC4 Project Information");
					Command sibGenerationCommand = commandService.getCommand("de.jabc.cinco.meta.core.jabcproject.commands.generateCincoSIBsCommand");
					sibGenerationCommand.executeWithChecks(event);
					
					// TODO: Product definition should be made central file
					System.out.println("Generating Product project");
					Command cpdGenerationCommand = commandService.getCommand("cpd.handler.ui.generate");
					cpdGenerationCommand.executeWithChecks(event);
					
					System.out.println("Generating Feature Project");
					Command featureGenerationCommand = commandService.getCommand("de.jabc.cinco.meta.core.generatefeature");
					featureGenerationCommand.executeWithChecks(event);
				}
				
				MessageDialog.openInformation(HandlerUtil.getActiveShell(event), "Cinco Product Generation", "Cinco Product generation completed successfully");
				
			}
		}catch(Exception e1){

			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e1.printStackTrace(pw);
			
			List<Status> children = new ArrayList<>();
			
			String pluginId = event.getTrigger().getClass().getCanonicalName();
			for (String line : sw.toString().split(System.lineSeparator())) {
				Status status = new Status(IStatus.ERROR, pluginId, line);
				children.add(status);
			}
			
			MultiStatus mstat = new MultiStatus(pluginId, IStatus.ERROR, children.toArray(new IStatus[children.size()]), e1.getLocalizedMessage(), e1);
			ErrorDialog.openError(HandlerUtil.getActiveShell(event), "Error in Cinco Product Generation", "An error occured during generation: ", mstat);
			
			e1.printStackTrace();
		}
		
		
		return null;
	}

	private CincoProduct loadCPD(IFile cpdFile) throws IOException, CoreException {
		System.out.println(cpdFile);
		URI createPlatformResourceURI = URI.createPlatformResourceURI(cpdFile.getFullPath().toPortableString(), true);
		Resource res = Resource.Factory.Registry.INSTANCE.getFactory(createPlatformResourceURI, "cpd").createResource(createPlatformResourceURI);
		ResourceSet set = ProductDefinition.ProductDefinitionPackage.eINSTANCE.eResource().getResourceSet();
		res.load(cpdFile.getContents(),null);
		return (CincoProduct) res.getContents().get(0);
		
	}
	private void deleteGeneratedResources(IProject project){
		IResource toDelete = project.findMember("src-gen/");
		IProgressMonitor monitor = new NullProgressMonitor();
		
			try {
				if(toDelete!=null){
					toDelete.delete(org.eclipse.core.resources.IResource.FORCE,monitor);
				}
				toDelete = project.findMember("resources-gen/");
				if(toDelete!=null){
					toDelete.delete(org.eclipse.core.resources.IResource.FORCE,monitor);
				}
			} catch (CoreException e) {
				e.printStackTrace();
			}
		
	}
}
