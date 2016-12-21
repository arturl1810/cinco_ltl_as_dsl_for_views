package de.jabc.cinco.meta.core.utils.xtext;

import java.util.LinkedList;
import java.util.List;

import org.eclipse.core.runtime.IPath;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.ui.actions.OpenNewClassWizardAction;
import org.eclipse.jdt.ui.wizards.NewClassWizardPage;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;

public class AppearanceWizard extends Wizard implements INewWizard {

	private NewClassWizardPage page;
	private String path;
	
	public AppearanceWizard(IJavaProject project) {
		page = new NewClassWizardPage();
		OpenNewClassWizardAction action = new OpenNewClassWizardAction();
		action.setOpenEditorOnFinish(false);
		action.setConfiguredWizardPage(page);
		setPackage(project);
		
		LinkedList <String> interfacesNames = new LinkedList<>() ;
		interfacesNames.add("de.jabc.cinco.meta.core.ge.style.model.appearance.StyleAppearanceProvider<T>");
		page.setSuperInterfaces(interfacesNames , true);
		page.setMethodStubSelection(false, true, true, true);
		
		action.run();
		if(action.getCreatedElement() != null)
		{
			String name = action.getCreatedElement().getElementName();
			IPath ipath = action.getCreatedElement().getPath();
			setPath(ipath,name);
		}
		
	}

	private void setPackage(IJavaProject project)
	{
		IPackageFragmentRoot currentRoot;
		try 
		{
			IClasspathEntry[] rawEntries = project.getRawClasspath();
			IClasspathEntry entry = search(rawEntries, "src");
			if(entry != null)
			{
				currentRoot = project.findPackageFragmentRoot(entry.getPath()); 
				page.setPackageFragmentRoot(currentRoot, true);
			}
		} 
		catch (JavaModelException e) {
			e.printStackTrace();
		}
	}
	
	private IClasspathEntry search(IClasspathEntry[] entry, String str)
	{
		for(int i = 0; i<entry.length; i++)
		{
			String en = entry[i].toString();
			String[] split = en.split("/");  //Beispiel String[]: [, info.scce.cinco.product.binsearchtree, src-gen[CPE_SOURCE][K_SOURCE][isExported:false]]
			for(int j = 0; j< split.length; j++)
			{
				String s = split[j];  //Beispiel String : src[CPE_SOURCE][K_SOURCE][isExported:false]
				if(s.contains("["))
				{
					String[] folder = s.split("\\[");
					for(int k = 0; k < folder.length; k++)
					{
						String f = folder[k];
						if(f.equals(str))
							return entry[i];
					}
				}
			}
		}
		return null;
	}
	
	// Beispiel Path: info.scce.cinco.product.binsearchtree/src/info/scce/cinco/product/binsearchtree/action/test4.java 
	private void setPath(IPath ipath, String name)
	{
		String re = "";
		String p = ipath.toString();
		String[] split = p.split("/");
		re = split[3];
		for(int i = 4; i< split.length-1; i++)
		{
			re = re + "." + split[i];
		}
		re = re + "." + name;
		path = re;
	}
	
	public String getPath() {
		// TODO Auto-generated method stub
		return path;
	}

	
	
	
	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean performFinish() {
		// TODO Auto-generated method stub
		return true;
	}

}
