package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;

public class PerformAppearanceWizard {
	
	private String classPath = "";
	
	public PerformAppearanceWizard(EObject eObject) {
		execute(eObject);
	}

	private void execute(EObject eObject) {
		URI uri = eObject.eResource().getURI();
		String[] segments = uri.segments();
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IProject[] projects = root.getProjects();		
		String path = search(segments,projects);
		IJavaProject project = JavaCore.create(root.getProject(path));
		AppearanceWizard wizard = new AppearanceWizard(project);
		createPath(wizard,path);
		
	}

	private String search(String[] segments, IProject[] projects) {
		
			for(int i = 0; i< segments.length; i++)
			{
				for(int j = 0; j<projects.length; j++)
				{
					String seg = segments[i];
					String[] pro = projects[j].toString().split("/");
					if(seg.equals(pro[1])) return seg;
				}
			}
			return "";
		}
	private void createPath(AppearanceWizard wizard, String path)
	{
		classPath =  wizard.getPath();
	}

	public String getPath() {
		return classPath;
	}

}
