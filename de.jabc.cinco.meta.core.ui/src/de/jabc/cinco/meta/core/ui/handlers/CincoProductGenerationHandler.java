package de.jabc.cinco.meta.core.ui.handlers;



import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.commands.ICommandService;
import org.eclipse.ui.handlers.HandlerUtil;

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
	public Object execute(ExecutionEvent event) throws ExecutionException {
		try{
			commandService = (ICommandService)PlatformUI.getWorkbench().getService(ICommandService.class);
			StructuredSelection selection = (StructuredSelection)HandlerUtil.getActiveMenuSelection(event);
			if(selection.getFirstElement() instanceof IFile){
				System.out.println("Generating Ecore/GenModel from MGL...");
				Command mglGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.mgl.ui.mglgenerationcommand");
				mglGeneratorCommand.executeWithChecks(event);
				
				System.out.println("Generating Model Code from GenModel...");
				IFile mglModelFile = (IFile)selection.getFirstElement();
				GeneratorHelper.generateGenModelCode(mglModelFile);
				
				
				System.out.println("Generating Graphiti Editor...");
				Command graphitiEditorGeneratorCommand = commandService.getCommand("de.jabc.cinco.meta.core.ge.generator.generateeditorcommand");
				graphitiEditorGeneratorCommand.executeWithChecks(event);
				
				System.out.println("Generating Feature Project");
				Command featureGenerationCommand = commandService.getCommand("de.jabc.cinco.meta.core.generatefeature");
				featureGenerationCommand.executeWithChecks(event);
				
				System.out.println("Generating TransEM4 SIBs");
				Command sibGenerationCommand = commandService.getCommand("de.jabc.cinco.meta.core.sibgenerator.commands.generateCincoSIBsCommand");
				sibGenerationCommand.executeWithChecks(event);
				
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
}
