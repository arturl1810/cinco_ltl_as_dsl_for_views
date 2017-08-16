package de.jabc.cinco.meta.core.ui.pyroGenerate

import de.jabc.cinco.meta.core.ui.handlers.CincoProductGenerationHandler
import org.eclipse.e4.core.commands.internal.HandlerServiceImpl
import org.eclipse.e4.core.contexts.IEclipseContext
import org.eclipse.jface.action.IAction
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.IActionDelegate
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.commands.ICommandService
import org.eclipse.ui.handlers.IHandlerService
import org.eclipse.ui.internal.handlers.E4HandlerProxy
import org.eclipse.ui.internal.handlers.HandlerProxy

class PyroGeneration implements IActionDelegate {
	new() { // TODO Auto-generated constructor stub
	}

	override void run(IAction action) { // TODO Auto-generated method stub
		val handlerService = PlatformUI.getWorkbench().getService(IHandlerService) as IHandlerService
		
		
		val eclipseContext = PlatformUI.getWorkbench().getService(IEclipseContext) as IEclipseContext; 
		val obj = HandlerServiceImpl.lookUpHandler(eclipseContext, "de.jabc.cinco.meta.core.ui.cincoproductgenerationcommand");
		if (obj instanceof E4HandlerProxy) { 
		   val e4HandlerProxy = obj;
		   var activeHandler = e4HandlerProxy.getHandler() as HandlerProxy; 
		      if (activeHandler.handler instanceof CincoProductGenerationHandler) {
		         val CincoProductGenerationHandler dHandler = activeHandler.handler as CincoProductGenerationHandler;
		         dHandler.pyroOnly
		      }
		}
		
		
		val commandService = PlatformUI.workbench.getService(ICommandService) as ICommandService
		val handler = commandService.getCommand("de.jabc.cinco.meta.core.ui.cincoproductgenerationcommand").handler
		if(handler instanceof CincoProductGenerationHandler){
			handler.pyroOnly
		}
		handlerService.executeCommand("de.jabc.cinco.meta.core.ui.cincoproductgenerationcommand",null)
	}

	override void selectionChanged(IAction action, ISelection selection) { // TODO Auto-generated method stub
	}
}
