package de.jabc.cinco.meta.plugin.gratext;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.runtime.xapi.FileExtension;
import mgl.GraphModel;

public class GratextGenerationHandler extends AbstractHandler {

	private static FileExtension fileHelper = new FileExtension();
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile mglFile = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		if (mglFile == null) 
			return null;
		GraphModel model = fileHelper.getContent(mglFile, GraphModel.class, 0);
		
		GratextPlugin plugin = new GratextPlugin();
		plugin.setCpd(MGLSelectionListener.INSTANCE.getSelectedCPD());
		plugin.setModel(model);
		plugin.run();
		
		return null;
	}
}
