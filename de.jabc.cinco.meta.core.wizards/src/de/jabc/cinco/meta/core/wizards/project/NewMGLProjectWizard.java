package de.jabc.cinco.meta.core.wizards.project;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.core.wizards.templates.CincoProductWizardTemplates;

public class NewMGLProjectWizard extends Wizard implements IWorkbenchWizard{

	@Override
	public void addPages() {
		NewMGLProjectWizardPage page = new NewMGLProjectWizardPage("mglWizard");
		addPage(page);
		super.addPages();
	}
	
	@Override
	public boolean performFinish() {
		IWizardPage page = getPage("mglWizard");
		if (page != null && page instanceof NewMGLProjectWizardPage) {
			NewMGLProjectWizardPage mglPage = (NewMGLProjectWizardPage) page;
			String projectName = mglPage.getProjectName();
			String packageName = mglPage.getPackageName();
			String mglModelName = mglPage.getModelName();
			mglModelName = (mglModelName.endsWith(".mgl")) ? mglModelName.split("\\.")[0] : mglModelName;
			String mglModelFileName = mglModelName.concat(".mgl");
			String styleModelFileName = mglModelName.concat(".style");
			String appearanceProviderFileName = "SimpleArrowAppearance.java";
			
			IProgressMonitor monitor = new NullProgressMonitor();
			
			IProject project = ProjectCreator.createProject(
					projectName, 
					getSrcFolders(), 
					null, 
					getReqBundles(), 
					getExportedPackages(packageName), 
					getNatures(), 
					monitor
			);
			
			try {
				IFolder modelFolder = project.getFolder("model");
				create(modelFolder, monitor);
				
				IFolder iconsFolder = project.getFolder("icons");
				create (iconsFolder, monitor);
				
				IFolder appearanceFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/appearance");
				create(appearanceFolder, monitor); 
				
//				copyIcons(project, monitor);
				
				IFile mglModelFile = modelFolder.getFile(mglModelFileName);
				createDummyMGLModel(mglModelFile, mglModelName, packageName, projectName);
				
				IFile styleModelFile = modelFolder.getFile(styleModelFileName);
				createDummyStyleModel(styleModelFile, packageName);
				
				IFile appearanceProviderFile = appearanceFolder.getFile(appearanceProviderFileName);
				createAppearanceProvider(appearanceProviderFile, mglModelName, packageName);
				
				project.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
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
	
	private List<String> getExportedPackages(String packageName) {
		List<String> exports = new ArrayList<String>();
		exports.add(packageName + ".appearance");
		return exports;
	}

	private Set<String> getReqBundles() {
		Set<String> list = new  HashSet<String>();
		list.add("org.eclipse.core.runtime");
		list.add("org.eclipse.emf.ecore");
		list.add("de.jabc.cinco.meta.core.mgl.model");
		list.add("de.jabc.cinco.meta.core.ge.style.model");
		list.add("de.jabc.cinco.meta.core.ge.style");
		return list;
	}

	private List<String> getSrcFolders() {
		List<String> folders = new ArrayList<String>();
		folders.add("src");
		folders.add("model");
		return folders;
	}
	
	private List<String> getNatures() {
		List<String> natures = new ArrayList<String>();
		natures.add("org.eclipse.xtext.ui.shared.xtextNature");
		return natures;
	}
	
	private void createDummyMGLModel(IFile modelFile, String modelName, String packageName, String projectName) {		
		CharSequence cs = CincoProductWizardTemplates.generateMGLFile(modelName, packageName, projectName);
		try {
			createFile(modelFile, cs.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void createDummyStyleModel(IFile modelFile, String packageName) {		
		CharSequence cs = CincoProductWizardTemplates.generateStyleFile(packageName);
		try {
			createFile(modelFile, cs.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	private void createAppearanceProvider(IFile modelFile, String modelName, String packageName) {		
		CharSequence cs = CincoProductWizardTemplates.generateAppearanceProvider(modelName, packageName);
		try {
			createFile(modelFile, cs.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	private void createFile(IFile file, String content) throws CoreException{
		file.create(new ByteArrayInputStream(content.getBytes()), true, new NullProgressMonitor());
	}
	
	/**
	 * recursively create resources.
	 * taken from here: https://www.eclipse.org/forums/index.php/mv/msg/91710/282873/#msg_282873
	 * 
	 */
	private void create(final IResource resource, IProgressMonitor monitor) throws CoreException {
		if (resource == null || resource.exists())
			return;
		if (!resource.getParent().exists())
			create(resource.getParent(),monitor);
		
		switch (resource.getType()) {
		case IResource.FILE :
			((IFile) resource).create(new ByteArrayInputStream(new byte[0]),
					true, monitor);
			break;
		case IResource.FOLDER :
			((IFolder) resource).create(IResource.NONE, true, monitor);
			break;
		case IResource.PROJECT :
			((IProject) resource).create(monitor);
			((IProject) resource).open(monitor);
			break;
		}
	}

	
	
}
