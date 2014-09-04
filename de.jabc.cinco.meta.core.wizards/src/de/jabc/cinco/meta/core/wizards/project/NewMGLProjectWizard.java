package de.jabc.cinco.meta.core.wizards.project;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.EnumSet;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.osgi.framework.Bundle;

public class NewMGLProjectWizard extends Wizard implements IWorkbenchWizard{
	
	MainPage mainPage = new MainPage("mainPage");
	CreateExampleProjectPage examplesPage = new CreateExampleProjectPage("examplesPage");
	CreateNewProjectPage newProjectPage = new CreateNewProjectPage("newProjectPage");

	@Override
	public void addPages() {
		addPage(mainPage);
		addPage(examplesPage);
		addPage(newProjectPage);
		super.addPages();
	}
	
	@Override
	public IWizardPage getNextPage(IWizardPage page) {
		if (page == mainPage) {
			if (mainPage.isCreateExample()) {
				return examplesPage;
			}
			else {
				return newProjectPage;
			}
		}
		else {
			return null;
		}
	}
	
	@Override
	public boolean canFinish() {
		if (mainPage.isCreateExample()) {
			return examplesPage.isPageComplete();
		}
		else {
			return newProjectPage.isPageComplete();
		}
	}
	
	@Override
	public boolean performFinish() {
		String projectName;
		String packageName;
		String mglModelName;
		Set<ExampleFeature> features = EnumSet.noneOf(ExampleFeature.class);
		
		if (mainPage.isCreateExample()) {
			projectName = examplesPage.getProjectName();
			packageName = examplesPage.getPackageName();
			mglModelName = examplesPage.getModelName();
			if (examplesPage.isGenerateAppearanceProvider()) {
				features.add(ExampleFeature.APPEARANCE_PROVIDER);
			}
			if (examplesPage.isGenerateCodeGenerator()) {
				features.add(ExampleFeature.CODE_GENERATOR);
			}
			if (examplesPage.isGenerateContainers()) {
				features.add(ExampleFeature.CONTAINERS);
			}
			if (examplesPage.isGenerateCustomAction()) {
				features.add(ExampleFeature.CUSTOM_ACTION);
			}
			if (examplesPage.isGeneratePrimeRefs()) {
				features.add(ExampleFeature.PRIME_REFERENCES);
			}
			
		}
		else {
			projectName = newProjectPage.getProjectName();
			packageName = newProjectPage.getPackageName();
			mglModelName = newProjectPage.getModelName();
		}
		
		CincoProductProjectCreator projectCreator = new CincoProductProjectCreator(
				projectName, packageName, mglModelName, mainPage.isCreateExample(), features);
		
		projectCreator.create();
		
		return true;
		
		
	}
	
	private void copyIcons(IProject p, IProgressMonitor monitor) {
		Bundle b = Platform.getBundle("de.jabc.cinco.meta.core.ge.generator");
		String location = b.getLocation();
		InputStream fis=null;
		try {
			
			fis = FileLocator.openStream(b, new Path("/icons/Connection.gif"), false);
			File trgFile = p.getFolder("icons").getFile("Connection.gif").getLocation().toFile();
			trgFile.createNewFile();
			OutputStream os = new FileOutputStream(trgFile);
			int bt;
			while ((bt = fis.read()) != -1) {
				os.write(bt);
			}
			fis.close();
			os.flush();
			os.close();
			
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			
			e.printStackTrace();
		}
//		if (resProject.exists()) {
//			IFolder srcIcons = resProject.getFolder("icons");
//			if (srcIcons.exists()) {
//				try {
//					srcIcons.copy((IPath) p.getFolder("icons"), true, monitor);
//				} catch (CoreException e) {
//					// TODO Auto-generated catch block
//					e.printStackTrace();
//				}
//			}
//		}
		
	}

	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		setWindowTitle("New Cinco Product Project");
	}

	
	
}
