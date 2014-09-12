package de.jabc.cinco.meta.core.sibgenerator.handlers;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import org.apache.tools.ant.taskdefs.Java;
import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;

import de.metaframe.jabc.editor.JavaABC;

public class StartJABCHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IWorkbenchWindow window = HandlerUtil
		.getActiveWorkbenchWindowChecked(event);
		IProgressService ps = window.getWorkbench()
				.getProgressService();
		try {
			ps.run(true, false, new JavaABCRunner());
		} catch (InvocationTargetException e) {
			throw new ExecutionException("Error in running jABC",e);
			
		} catch (InterruptedException e) {
			throw new ExecutionException("Error in running jABC",e);
		}
		
		return null;
	}

	

	private class JavaABCRunner implements IRunnableWithProgress{
		
		@Override
		/**
		 * Contains code from: http://stackoverflow.com/questions/1229605/
		 */
		public void run(IProgressMonitor monitor)
				throws InvocationTargetException, InterruptedException {
			
			JavaABC.main(new String[0]);
		
			
		}
		
		
		
		
		
	}
	
}
