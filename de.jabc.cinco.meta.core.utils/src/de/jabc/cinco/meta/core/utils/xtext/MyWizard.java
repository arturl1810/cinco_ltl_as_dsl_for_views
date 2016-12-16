package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.core.runtime.IPath;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.ui.actions.OpenNewClassWizardAction;
import org.eclipse.jdt.ui.wizards.NewClassWizardPage;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.INewWizard;
import org.eclipse.ui.IWorkbench;

public class MyWizard extends Wizard implements INewWizard {
	
	private NewClassWizardPage page;
	private String path;
	
	public MyWizard(IJavaProject project, String superClass, String className, String packageName) {
		// TODO Auto-generated constructor stub
		page = new NewClassWizardPage();
		OpenNewClassWizardAction action = new OpenNewClassWizardAction();
		action.setOpenEditorOnFinish(false);
		action.setConfiguredWizardPage(page);
		setPackage(project);
		
		page.setSuperClass(superClass, true);
		page.setMethodStubSelection(false, true, true, true);		
		page.setTypeName(className, true);		
		IPackageFragmentRoot root = project.getPackageFragmentRoot(project.getProject());
		IPackageFragment packageFragment = root.getPackageFragment(packageName);
		page.setPackageFragment(packageFragment, true);
		
		
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
			// TODO Auto-generated catch block
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
	
	public String getPath()
	{
		return path;
	}
	
	@Override
	public void addPages() {
		// TODO Auto-generated method stub
//		super.addPages();
//		page = new NewClassWizardPage();
//		addPage(page);
	}
	
	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		// TODO Auto-generated method stub
	}

	@Override
	public boolean performFinish() {
		//System.out.println("tedt");
		return true;
	}

}
