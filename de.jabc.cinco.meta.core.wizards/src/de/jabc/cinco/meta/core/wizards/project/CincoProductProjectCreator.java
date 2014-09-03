package de.jabc.cinco.meta.core.wizards.project;

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.APPEARANCE_PROVIDER;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.CODE_GENERATOR;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.CUSTOM_ACTION;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.core.wizards.templates.CincoProductWizardTemplates;

public class CincoProductProjectCreator {
	
	private final String projectName;
	private final String packageName;
	private final String mglModelName;
	private final boolean createExample;
	private final Set<ExampleFeature> features;
	
	public CincoProductProjectCreator(String projectName, String packageName, String mglModelName, boolean createExample, Set<ExampleFeature> features) {
		this.projectName = projectName;
		this.packageName = packageName;
		this.mglModelName = (mglModelName.endsWith(".mgl")) ? mglModelName.split("\\.")[0] : mglModelName;
		this.createExample = createExample;
		if (createExample)
			this.features = features;
		else
			this.features = Collections.emptySet();
	}
	
	public void create() {

		IProgressMonitor monitor = new NullProgressMonitor();

		IProject project = ProjectCreator.createProject(
				projectName, 
				getSrcFolders(), 
				null, 
				getReqBundles(), 
				getExportedPackages(), 
				getNatures(), 
				monitor
				);

		try {
			IFolder modelFolder = project.getFolder("model");
			createResource(modelFolder, monitor);
			IFile mglModelFile = modelFolder.getFile(mglModelName.concat(".mgl"));
			IFile styleModelFile = modelFolder.getFile(mglModelName.concat(".style"));
			if (createExample) {
				createFlowGraphMGLModel(mglModelFile);
				createFlowGraphStyleModel(styleModelFile);
			}
			else {
				//TODO: create SomeGraph code
			}

			/*
				IFolder iconsFolder = project.getFolder("icons");
				create (iconsFolder, monitor);
				copyIcons(project, monitor);
			 */

			if (features.contains(APPEARANCE_PROVIDER)) {
				IFolder appearanceFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/appearance");
				createResource(appearanceFolder, monitor); 
				IFile appearanceProviderFile = appearanceFolder.getFile("SimpleArrowAppearance.java");
				createAppearanceProvider(appearanceProviderFile, mglModelName, packageName);
			}

			project.refreshLocal(IResource.DEPTH_INFINITE, monitor);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	private List<String> getExportedPackages() {
		List<String> exports = new ArrayList<String>();
		if (features.contains(APPEARANCE_PROVIDER)) {
			exports.add(packageName + ".appearance");
		}
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
		
		Set<ExampleFeature> codeFeatures = EnumSet.of(APPEARANCE_PROVIDER, CODE_GENERATOR, CUSTOM_ACTION);
		
		if (!Collections.disjoint(features,codeFeatures)) {
			folders.add("src");
		}
	
		folders.add("model");
		return folders;
	}

	private List<String> getNatures() {
		List<String> natures = new ArrayList<String>();
		natures.add("org.eclipse.xtext.ui.shared.xtextNature");
		return natures;
	}

	private void createFlowGraphMGLModel(IFile modelFile) {		
		CharSequence cs = CincoProductWizardTemplates.generateMGLFile(mglModelName, packageName, projectName);
		try {
			createFile(modelFile, cs.toString());
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void createFlowGraphStyleModel(IFile modelFile) {		
		CharSequence cs = CincoProductWizardTemplates.generateStyleFile(packageName, features);
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
	private void createResource(final IResource resource, IProgressMonitor monitor) throws CoreException {
		if (resource == null || resource.exists())
			return;
		if (!resource.getParent().exists())
			createResource(resource.getParent(),monitor);
		
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
