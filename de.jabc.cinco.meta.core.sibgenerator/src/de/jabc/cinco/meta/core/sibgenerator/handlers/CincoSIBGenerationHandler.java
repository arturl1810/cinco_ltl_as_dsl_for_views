package de.jabc.cinco.meta.core.sibgenerator.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;

import de.jabc.cinco.meta.core.sibgenerator.CincoSIBGenerator;
import org.apache.log4j.Logger;
/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class CincoSIBGenerationHandler extends AbstractHandler {
	
	public static Logger logger = Logger.getLogger("de.jabc.adapter.common.basic.LightweightServiceAdapter");
	
	/**
	 * The constructor.
	 */
	public CincoSIBGenerationHandler() {
	}

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IWorkbenchWindow window = HandlerUtil.getActiveWorkbenchWindowChecked(event);
		ISelection selection = HandlerUtil.getActiveMenuSelection(event);
		if(selection!=null&&selection instanceof StructuredSelection){
			StructuredSelection structSelection = (StructuredSelection)selection;
			if(structSelection.getFirstElement()instanceof IFile){
				IFile file = (IFile)structSelection.getFirstElement();
				if(file!=null &&file.getFileExtension().equals("ecore")){
					try{
						IPath modelPath = file.getLocation();
						IPath outlet = file.getProject().getLocation().append("sib-gen").makeAbsolute();
						if(!outlet.toFile().exists())
							outlet.toFile().mkdirs();
						System.out.println(outlet);	
						String packageName = file.getProject().getName();
						IProgressService ps = window.getWorkbench().getProgressService();
						ps.busyCursorWhile(new CincoSIBGenerator(modelPath,outlet,packageName,file.getProject()));
						
					}catch(Exception e){
						e.printStackTrace();
					}
				}
				
			}
		}
		return null;
	}
}
