package de.jabc.cinco.meta.core.ui.forceGenerate

import de.jabc.cinco.meta.core.ui.handlers.CincoProductGenerationHandler
import java.io.File
import java.io.IOException
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.resources.IFile
import org.eclipse.jface.action.IAction
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IActionDelegate
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.commands.ICommandService
import org.eclipse.ui.handlers.IHandlerService

class ForceGenerateAction implements IActionDelegate {
	ISelection selection

	new() { // TODO Auto-generated constructor stub
	}

	override void run(IAction action) {
		if (selection instanceof IStructuredSelection) {
			val iFile = selection.firstElement as IFile
			val filePath = CincoProductGenerationHandler::getFilePath(iFile);
			val fname = new File(filePath);
			try {
				fname.delete();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
//			val commandService = PlatformUI.getWorkbench().getService(ICommandService) as ICommandService
			
			val handlerService = PlatformUI.getWorkbench().getService(IHandlerService) as IHandlerService
			
			handlerService.executeCommand("de.jabc.cinco.meta.core.ui.cincoproductgenerationcommand",null)
			
			//commandService.getCommand("de.jabc.cinco.meta.core.ui.cincoproductgenerationcommand").executeWithChecks(new ExecutionEvent());
		}
	}

	override void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection
	}
}
