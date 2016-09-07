package de.jabc.cinco.meta.plugin.gratext;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import mgl.GraphModel;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.jobs.Job;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.WorkspaceUtil;
import de.jabc.cinco.meta.plugin.gratext.build.GratextModelBuild;

public class GratextGenerationHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile mglFile = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		if (mglFile == null) 
			return null;
		IProject mglProject = mglFile.getProject();
		
		GraphModel model = WorkspaceUtil.resp(mglFile).getResourceContent(GraphModel.class, 0);
		
		Map<String, Object> ctx = new HashMap<>();
		ctx.put("graphModel", model);
		
		GratextGenerator gratextGen = new GratextGenerator(model);
		IProject gratextProject = gratextGen.execute(ctx);
		GeneratedGratextProjectRegistry.INSTANCE.add(gratextProject);
		
		GratextUiProjectGenerator gratextUiGen = new GratextUiProjectGenerator();
		gratextUiGen.execute(ctx);
		
		execute(new GratextModelBuild(gratextProject));
		
		build(mglProject);
		build(gratextProject);
		
		gratextGen.proceed();
		
//		new GratextLanguageGenerator(model).execute(ctx);
		
		
//		execute(new GratextLanguageBuild(gratextProject));
		
		return null;
	}
	
	private void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void execute(Job job) {
		job.schedule();
		try {
			job.join();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	private List<String> list(String... strs) {
		return Arrays.asList(strs);
	}
	
	private Set<String> set(String... strs) {
		return new HashSet<>(list(strs));
	}
}
