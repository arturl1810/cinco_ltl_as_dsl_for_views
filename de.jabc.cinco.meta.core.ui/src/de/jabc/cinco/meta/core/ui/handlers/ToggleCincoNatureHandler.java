package de.jabc.cinco.meta.core.ui.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;

import de.jabc.cinco.meta.core.ui.CincoNature;

public class ToggleCincoNatureHandler extends AbstractHandler{




	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		try{
		StructuredSelection selection = (StructuredSelection)HandlerUtil.getActiveMenuSelection(event);
		IProject project = (IProject)selection.getFirstElement();
		CincoNature nature = new CincoNature();
		nature.setProject(project);
		
		if(!project.hasNature("de.jabc.cinco.meta.core.CincoNature")){
			nature.configure();
		}else{
			nature.deconfigure();
		}
		
		}catch(ClassCastException ce){} catch (CoreException e) {
			throw new ExecutionException("Could not toggle Cinco Nature",e);
			
		}
		return null;
	}


}
