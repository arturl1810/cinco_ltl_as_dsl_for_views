package de.jabc.cinco.meta.core.sibgenerator.handlers;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.jar.Manifest;

import org.apache.log4j.Logger;
import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;

import de.jabc.cinco.meta.core.sibgenerator.CincoSIBGenerator;
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
						IPath outlet = file.getProject().getLocation().append("src-gen").makeAbsolute();
						if(!outlet.toFile().exists())
							outlet.toFile().mkdirs();
						String packageName = file.getProject().getName();
						IProgressService ps = window.getWorkbench().getProgressService();
						prepareProject(file.getProject());
						ps.busyCursorWhile(new CincoSIBGenerator(modelPath,outlet,packageName,file.getProject()));
						
					}catch(Exception e){
						e.printStackTrace();
					}
				}
				
			}
		}
		return null;
	}

	private void prepareProject(IProject project) {
		Manifest mani = new Manifest();
		try {
			mani.read(new FileInputStream(project.getLocation().append("META-INF/MANIFEST.MF").toFile()));
			System.out.println("*** Manifest Attributes ***");
			String oldValue = mani.getMainAttributes().getValue("Require-Bundle");
			if(!oldValue.contains("de.jabc.cinco.meta.libraries")){
				oldValue = oldValue.concat(",de.jabc.cinco.meta.libraries");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			if(!oldValue.contains("org.eclipse.xtend.typesystem.emf")){
				oldValue = oldValue.concat(",org.eclipse.xtend.typesystem.emf");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			if(!oldValue.contains("org.eclipse.emf.ecore.xmi")){
				oldValue = oldValue.concat(",org.eclipse.emf.ecore.xmi");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			mani.write(new FileOutputStream(project.getLocation().append("META-INF/MANIFEST.MF").toFile()));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}
}
