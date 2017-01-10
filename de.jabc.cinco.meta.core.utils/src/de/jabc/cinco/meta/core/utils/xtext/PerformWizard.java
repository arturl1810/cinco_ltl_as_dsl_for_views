package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;

import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoCustomAction;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoDoubleClickAction;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPostCreateHook;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPostMoveHook;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPostResizeHook;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPostSelectHook;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPostValueChangeListener;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoPreDeleteHook;
import de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature.CincoValuesProvider;
import mgl.Annotation;
import mgl.ModelElement;



public class PerformWizard { 

	private String classPath = "";
	private ModelElement model;
	
	public PerformWizard(Annotation annot) {
		model = (ModelElement) annot.getParent();
		String name = annot.getName();
		String superClassName = chooseSuperclass(name);
		
		String value = annot.getValue().get(0);
		String className = getClassName(value);
		String packageName = getPackageName(value);
		
		execute(model, superClassName, className, packageName);
		
	}


	public void execute(ModelElement modelElement, String superclass, String className, String packageName) {
		URI uri = modelElement.eResource().getURI();
		String[] segments = uri.segments();
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IProject[] projects = root.getProjects();		
		String path = search(segments,projects);
		IJavaProject project = JavaCore.create(root.getProject(path));
		MyWizard wizard = new MyWizard(project, superclass, className, packageName);
		createPath(wizard,path);
	}
	
	private String search(String[] segments, IProject[] projects)
	{
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
			

	//private
	public String chooseSuperclass(String name)
	{
		String superclass = "";
		if(name.equals("doubleClickAction"))
			superclass = CincoDoubleClickAction.class.getName();
		else if(name.equals("postCreate"))
			superclass = CincoPostCreateHook.class.getName();
		else if(name.equals("postMove"))
			superclass = CincoPostMoveHook.class.getName();
		else if(name.equals("postResize"))
			superclass = CincoPostResizeHook.class.getName();
		else if(name.equals("postSelect"))
			superclass = CincoPostSelectHook.class.getName();
		else if(name.equals("postAttributeValueChange"))
				superclass = CincoPostValueChangeListener.class.getName();
		else if(name.equals("preDelete"))
			superclass = CincoPreDeleteHook.class.getName();
		else if(name.equals("possibleValueProvider"))
			superclass = CincoValuesProvider.class.getName();
		else if (name.equals("contextMenuAction"))
				superclass = CincoCustomAction.class.getName();
		return superclass;
	}
	
	private String getClassName(String name){
		String className = "";
		if(name.contains(".")){
			className = name.substring(name.lastIndexOf(".")+1);
		}
		else{
			className = name;

		}
		return className;
	}
	
	private String getPackageName(String name){
		String packageName = "";
		if(name.contains(".")){
			String withoutClassName = name.substring(0, name.lastIndexOf("."));
			packageName = withoutClassName;						
		}
		return packageName;
	}
	
	private void createPath(MyWizard wizard, String path)
	{
		classPath =  wizard.getPath();
	}

	public String getPath()
	{
		return classPath;
	}
}
