package de.jabc.cinco.meta.plugin.gratext;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import mgl.GraphModel;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.jobs.Job;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.EclipseFileUtils;
import de.jabc.cinco.meta.plugin.gratext.build.GratextModelBuild;
import de.jabc.cinco.meta.runtime.xapi.FileExtension;
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension;

public class GratextGenerationHandler extends AbstractHandler {

	private static FileExtension files = new FileExtension();
	private static WorkspaceExtension workspace = new WorkspaceExtension();
	
	private static String ANTLR_PATCH_FILENAME = ".antlr-generator-3.2.0-patch.jar";
	private static String DOWNLOAD_URL = "http://download.itemis.com/antlr-generator-3.2.0-patch.jar";
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile mglFile = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		if (mglFile == null) 
			return null;
		
		GraphModel model = files.getContent(mglFile, GraphModel.class, 0);
		
		Map<String, Object> ctx = new HashMap<>();
		ctx.put("graphModel", model);
		
		GratextGenerator gratextGen = new GratextGenerator(model);
		IProject gratextProject = gratextGen.execute(ctx);
		GeneratedGratextProjectRegistry.INSTANCE.add(gratextProject);
		
		GratextUiProjectGenerator gratextUiGen = new GratextUiProjectGenerator();
		gratextUiGen.execute(ctx);
		
		execute(new GratextModelBuild(gratextProject));
		
		build(mglFile.getProject());

		IProject graphitiProject = workspace.getWorkspaceRoot().getProject(model.getPackage() + ".editor.graphiti");
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
		
		assertAntlrPatch(gratextProject);
		
		return null;
	}
	
	private void build(IProject project) {
		try {
			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
		} catch (CoreException e) {
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
	
	private void assertAntlrPatch(IProject project) {
		IFile file = project.getFile(new Path(ANTLR_PATCH_FILENAME));
		if (!file.exists()) {
			copyAntlrPatch(project);
			
//			IFile antlrPatch = findAntlrPatch();
//			if (antlrPatch == null) {
//				antlrPatch = downloadAntlrPatch(project);
//			} else try {
//				file.create(antlrPatch.getContents(), true, null);
//			} catch(CoreException e) {
//				e.printStackTrace();
//			}
		}
	}
	
	private void copyAntlrPatch(IProject project) {
		EclipseFileUtils.copyFromBundleToFile(
			"de.jabc.cinco.meta.libraries",
			"lib_local/antlr-generator-3.2.0-patch.jar",
			project.getFile(".antlr-generator-3.2.0-patch.jar"));
	}
	
	private IFile findAntlrPatch() {
		for (IProject project : ResourcesPlugin.getWorkspace().getRoot().getProjects()) {
			IFile file = project.getFile(new Path(ANTLR_PATCH_FILENAME));
			if (file.exists())
				return file;
		}
		return null;
	}
	
	private IFile downloadAntlrPatch(IProject project) {
		try {
			BufferedInputStream stream = new BufferedInputStream(new URL(DOWNLOAD_URL).openStream());
			return workspace.createFile(project, ANTLR_PATCH_FILENAME, stream);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
}
