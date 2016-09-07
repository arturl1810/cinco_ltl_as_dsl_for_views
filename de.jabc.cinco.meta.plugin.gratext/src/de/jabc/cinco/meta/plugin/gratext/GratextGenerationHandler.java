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

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.WorkspaceUtil;
import de.jabc.cinco.meta.plugin.gratext.build.GratextBuild;

public class GratextGenerationHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("### Generate Gratext: ");
		
		IFile mglFile = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		
		if (mglFile == null) 
			return null;
		
		GraphModel model = WorkspaceUtil.resp(mglFile).getResourceContent(GraphModel.class, 0);

		System.err.println("### Model: " + model.getName());
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		System.err.println("###");
		
		Map<String, Object> ctx = new HashMap<>();
		ctx.put("graphModel", model);
		
		IProject project = new GratextProjectGenerator().execute(ctx);
		
//		spawnJob(project);
		
		return null;
	}
	
	private void spawnJob(IProject project) {
		GratextBuild job = new GratextBuild(project);
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
