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
			features.addAll(examplesPage.getSelectedFeatures());
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
	
	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		setWindowTitle("New Cinco Product Project");
	}

	
	
}
