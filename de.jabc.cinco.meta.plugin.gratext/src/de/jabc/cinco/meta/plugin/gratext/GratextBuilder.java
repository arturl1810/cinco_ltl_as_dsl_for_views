package de.jabc.cinco.meta.plugin.gratext;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;

import de.jabc.cinco.meta.plugin.gratext.build.GratextLanguageBuild;

public class GratextBuilder extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IProject project = GeneratedGratextProjectRegistry.INSTANCE.poll();
		if (project == null)
			return null;
		
		
		GratextLanguageBuild job = new GratextLanguageBuild(project);
		job.schedule();
		
		try {
			job.join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	
}
