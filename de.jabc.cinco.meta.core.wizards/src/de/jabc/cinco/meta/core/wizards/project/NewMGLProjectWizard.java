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
			
			IProgressMonitor monitor = new NullProgressMonitor();
			
			IProject project = ProjectCreator.createProject(
					projectName, getSrcFolders(), null, getReqBundles(), null, getNatures(), monitor);
			IFolder modelFolder = project.getFolder("model");
			IFolder iconsFolder = project.getFolder("icons");
			
			
			
			try {
				if (!modelFolder.exists()) {
					modelFolder.create(true, true, monitor);
				}
				if (!iconsFolder.exists()) {
					iconsFolder.create(true, true, monitor);
				}
				
//				copyIcons(project, monitor);
				
				IFile mglModelFile = modelFolder.getFile(mglModelFileName);
				IFile styleModelFile = modelFolder.getFile(styleModelFileName);
				createDummyMGLModel(mglModelFile, mglModelName, packageName);
				createDummyStyleModel(styleModelFile, mglModelName, packageName);
				
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
		setWindowTitle("New Meta Graph Language Project");
	}

	private Set<String> getReqBundles() {
		Set<String> list = new  HashSet<String>();
		list.add("org.eclipse.core.runtime");
		list.add("org.eclipse.emf.ecore");
		list.add("de.jabc.cinco.meta.core.mgl.model");
		list.add("de.jabc.cinco.meta.core.ge.style.model");
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
	
	private void createDummyMGLModel(IFile modelFile, String modelName, String packageName) {		
		StringBuilder sb = new StringBuilder();
		sb.append("@Style(\"/"+packageName+"/model/"+modelName+".style\")\n");
		sb.append("graphModel " + modelName + "{\n\tpackage " + packageName + "\n\t" +"nsURI \"http://de/test/project/"+modelName.toLowerCase()+"\"\n\t");
		sb.append("diagramExtension \"\"\n");
		sb.append("\n\t@Style(NodeStyle)\n");
		sb.append("\tnode Start{\n\n\t}\n\t"
				+ "@Style(NodeStyle)\n"
				+ "\tnode End{\n\n\t}\n\n\t");
		
		sb.append("@Style(EdgeStyle)\n");
		sb.append("\tedge Succ{\n\t\ttargetNodes(End)\n\t\tsourceNodes(Start)\n\t}\n}");
		
		try {
			createFile(modelFile, sb.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	private void createDummyStyleModel(IFile modelFile, String modelName, String packageName) {		
		StringBuilder sb = new StringBuilder();
		sb.append("appearance green {\n\tbackground(0,255,0)\n}");
		sb.append("\n\n");
		
		sb.append("nodeStyle NodeStyle {\n\t"
				+ "\t/*appearanceProvider (\"de.test.project.appearance.provider.MyAppearanceProvider\") */\n"
				+ "\tellipse outer {"
				+ "appearance green \n\t"
				+ "\tsize(50,50)\n"
				+ "\t\tellipse inner {"
				+ "appearance green \n\t"
				+ "\t\tposition relativeTo outer (CENTER, MIDDLE)\n"
				+ "\t\t\tsize (46,46)\n"
				+ "\t\t}\n"
				+ "\t}\n"
				+ "}\n");
		
		sb.append("\nedgeStyle EdgeStyle {\n"
				+ "\tappearance {\n"
				+ "\t\tlineStyle SOLID\n"
				+ "\t}\n"
				+ "}");
		
		try {
			createFile(modelFile, sb.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	
	
	private void createFile(IFile file, String content) throws CoreException{
		file.create(new ByteArrayInputStream(content.getBytes()), true, new NullProgressMonitor());
	}
	
}
