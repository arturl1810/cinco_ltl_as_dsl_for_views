package de.jabc.cinco.meta.core.ui.handlers;



import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;


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
	public Object execute(ExecutionEvent event) throws ExecutionException {
		try{
			commandService = (ICommandService)PlatformUI.getWorkbench().getService(ICommandService.class);
			StructuredSelection selection = (StructuredSelection)HandlerUtil.getActiveMenuSelection(event);
			if(selection.getFirstElement() instanceof IFile){
				
				System.out.println("Generating Ecore/GenModel from MGL...");
				Command mglGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
				mglGeneratorCommand.executeWithChecks(event);
				
				System.out.println("Generating Graphiti Editor...");
				Command graphitiEditorGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
				graphitiEditorGeneratorCommand.executeWithChecks(event);
				
				System.out.println("Generating Feature Project");
				Command featureGenerationCommand = commandService.getCommand("de.jabc.cinco.meta.core.generatefeature");
				featureGenerationCommand.executeWithChecks(event);
				
				MessageDialog.openInformation(HandlerUtil.getActiveShell(event), "Cinco Generation Process completed", "Genertion successfully completed!");
				
			}
		}catch(Exception e1){
			StringBuilder builder = new StringBuilder();
			StackTraceElement[] trace = null;
			
			IStatus status = new Status(Status.ERROR,event.getTrigger().getClass().getCanonicalName(),builder.toString(),e1);
			ErrorDialog.openError(HandlerUtil.getActiveShell(event), "Error in Cinco Product Generation", "An error occured during generation: ", status);
			
			e1.printStackTrace();
		}
		
		
		return null;
	}
}
