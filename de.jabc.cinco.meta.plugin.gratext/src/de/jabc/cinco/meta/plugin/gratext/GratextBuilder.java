package de.jabc.cinco.meta.plugin.gratext;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;

import de.jabc.cinco.meta.plugin.gratext.build.GratextLanguageBuild;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import de.jabc.cinco.meta.runtime.xapi.WorkspaceExtension;
import mgl.GraphModel;

public class GratextBuilder extends AbstractHandler {

	protected WorkspaceExtension workspace = new WorkspaceExtension();
	protected ResourceExtension resources = new ResourceExtension();
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		GratextGenerator gratextGen = GeneratedGratextProjectRegistry.INSTANCE.poll();
		if (gratextGen == null)
			return null;
		
		IProject gratextProject = gratextGen.project;
		GraphModel mglModel = gratextGen.model;
		
//		build(resources.getProject(mglModel.eResource()));

		IProject graphitiProject = workspace.getWorkspaceRoot().getProject(mglModel.getPackage() + ".editor.graphiti");
		if (graphitiProject != null && graphitiProject.exists()) {
			try {
				graphitiProject.close(null);
				graphitiProject.open(null);
			} catch (CoreException e) {
				e.printStackTrace();
			}
			build(graphitiProject);
		}

		build(gratextProject);
		
		gratextGen.proceed();
		
		GratextLanguageBuild job = new GratextLanguageBuild(gratextProject);
		job.schedule();
		
		try {
			job.join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	private void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
}
