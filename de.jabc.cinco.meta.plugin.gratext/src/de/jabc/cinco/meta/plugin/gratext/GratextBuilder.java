package de.jabc.cinco.meta.plugin.gratext;

import java.util.concurrent.LinkedTransferQueue;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;

import de.jabc.cinco.meta.plugin.dsl.PackageDescription;
import de.jabc.cinco.meta.plugin.gratext.build.GratextLanguageBuild;
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.GrammarTmpl;
import de.jabc.cinco.meta.plugin.gratext.tmpl.project.GratextProjectTmpl;
import de.jabc.cinco.meta.plugin.template.FileTemplate;
import de.jabc.cinco.meta.runtime.xapi.FileExtension;
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension;
import de.jabc.cinco.meta.runtime.xapi.WorkspaceExtension;
import mgl.GraphModel;

public class GratextBuilder extends AbstractHandler {

	public static LinkedTransferQueue<GratextProjectTmpl> PROJECT_REGISTRY = new LinkedTransferQueue<>();
	
	protected WorkspaceExtension workspace = new WorkspaceExtension();
	protected ResourceExtension resources = new ResourceExtension();
	protected FileExtension files = new FileExtension();
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		GratextProjectTmpl gratextProjTmpl = PROJECT_REGISTRY.poll();
		if (gratextProjTmpl == null)
			return null;
		
		IProject gratextProject = gratextProjTmpl.getProjectDescription().getIResource();
		GraphModel mglModel = gratextProjTmpl.getMglModel();
		
//		// workaround for phantom errors in Graphiti project
//		IProject graphitiProject = workspace.getWorkspaceRoot().getProject(mglModel.getPackage() + ".editor.graphiti");
//		if (graphitiProject != null && graphitiProject.exists()) {
//			try {
//				graphitiProject.close(null);
//				graphitiProject.open(null);
//			} catch (CoreException e) {
//				e.printStackTrace();
//			}
//			build(graphitiProject);
//		}
		
		workspace.buildIncremental(gratextProject);
		
		// workaround to put the .xtext file on the classpath without building the project
		try {
			FileTemplate tmpl = new GrammarTmpl();
			tmpl.setModel(mglModel);
			tmpl.setParent(new PackageDescription(mglModel.getPackage()+".gratext"));
			IFile file = createFile(
				mglModel.getPackage()+".gratext",
				"bin/"+mglModel.getPackage().replace('.', '/')+"/gratext/",
				mglModel.getName() + "Gratext.xtext",
				tmpl.getContent());
			file.setDerived(true, null);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		gratextProjTmpl.proceed(); // create additional files

		new GratextLanguageBuild(gratextProject).runAndWait();
		
		return null;
	}

//	private void build(IProject project) {
//		try {
//			project.build(IncrementalProjectBuilder.INCREMENTAL_BUILD, null);
//		} catch (CoreException e) {
//			e.printStackTrace();
//		}
//	}
	
	private IFile createFile(String projectName, String folderName, String fileName, CharSequence content) {
		IProject project = workspace.getWorkspaceRoot().getProject(projectName);
		IFolder folder = workspace.createFolder(project, folderName);
		return workspace.createFile(folder, fileName, content);
	}
}
