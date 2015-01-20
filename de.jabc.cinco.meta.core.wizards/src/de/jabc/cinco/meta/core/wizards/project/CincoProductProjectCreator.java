package de.jabc.cinco.meta.core.wizards.project;

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.APPEARANCE_PROVIDER;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.CODE_GENERATOR;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.CONTAINERS;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.CUSTOM_ACTION;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.ICONS;
import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.PRIME_REFERENCES;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

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
			IFile cpdModelFile = modelFolder.getFile(mglModelName.concat(".cpd"));
			if (!createExample) {
				CharSequence mglCode = CincoProductWizardTemplates.generateSomeGraphMGL(mglModelName, packageName);
				writeToFile(mglModelFile, mglCode);
				
				CharSequence styleCode = CincoProductWizardTemplates.generateSomeGraphStyle();
				writeToFile(styleModelFile, styleCode);
				
				
			}
			else {
				CharSequence mglCode = CincoProductWizardTemplates.generateFlowGraphMGL(mglModelName, packageName, projectName, features);
				writeToFile(mglModelFile, mglCode);
				
				CharSequence styleCode = CincoProductWizardTemplates.generateFlowGraphStyle(packageName, features);
				writeToFile(styleModelFile, styleCode);

				if (features.contains(APPEARANCE_PROVIDER)) {
					IFolder appearanceFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/appearance");
					createResource(appearanceFolder, monitor); 
					IFile appearanceProviderFile = appearanceFolder.getFile("SimpleArrowAppearance.java");
					CharSequence appearanceProviderCode = CincoProductWizardTemplates.generateAppearanceProvider(mglModelName, packageName);
					writeToFile(appearanceProviderFile, appearanceProviderCode);
				}
				if (features.contains(CODE_GENERATOR)) {
					IFolder codegenFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/codegen");
					createResource(codegenFolder, monitor);
					IFile codegenFile = codegenFolder.getFile("Generate.java");
					CharSequence codegenCode = CincoProductWizardTemplates.generateCodeGenerator(mglModelName, packageName);
					writeToFile(codegenFile, codegenCode);
				}
				if (features.contains(CUSTOM_ACTION)) {
					IFolder customActionFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/action");
					createResource(customActionFolder, monitor);
					IFile customActionFile = customActionFolder.getFile("ShortestPathToEnd.java");
					CharSequence customActionCode = CincoProductWizardTemplates.generateCustomAction(mglModelName, packageName);
					writeToFile(customActionFile, customActionCode);
				}
				if (features.contains(ICONS)){
					copyIcons(project);
				}
				if (features.contains(PRIME_REFERENCES)) {
					IFile externalLibraryEcoreFile = modelFolder.getFile("ExternalLibrary.ecore");
					CharSequence externalLibraryEcoreCode = CincoProductWizardTemplates.generatePrimeRefEcore(mglModelName, packageName);
					writeToFile(externalLibraryEcoreFile, externalLibraryEcoreCode);

					IFile externalLibraryGenmodelFile = modelFolder.getFile("ExternalLibrary.genmodel");
					CharSequence externalLibraryGenmodelCode = CincoProductWizardTemplates.generatePrimeRefGenmodel(
							mglModelName, packageName, projectName, ProjectCreator.makeSymbolicName(projectName));
					writeToFile(externalLibraryGenmodelFile, externalLibraryGenmodelCode);
				}
			}
			CharSequence cpdCode = CincoProductWizardTemplates.generateSomeGraphCPD(mglModelName, packageName,projectName);
			writeToFile(cpdModelFile, cpdCode);

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
		if (features.contains(CUSTOM_ACTION)) {
			exports.add(packageName + ".action");
		}
		if (features.contains(CODE_GENERATOR)) {
			exports.add(packageName + ".codegen");
		}
		return exports;
	}

	private Set<String> getReqBundles() {
		Set<String> bundles = new  HashSet<String>();
		bundles.add("org.eclipse.core.runtime");
		bundles.add("org.eclipse.emf.ecore");
		bundles.add("de.jabc.cinco.meta.core.mgl.model");
		bundles.add("de.jabc.cinco.meta.core.ge.style.model");
		bundles.add("de.jabc.cinco.meta.core.ge.style");
		if (features.contains(CUSTOM_ACTION)) {
			bundles.add("org.eclipse.jface");
		}
		return bundles;
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

	private void writeToFile(IFile file, CharSequence code) {		
		try {
			createFile(file, code.toString());
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

	private void copyIcons(IProject p) {
			Bundle sourceBundle = Platform.getBundle("de.jabc.cinco.meta.core.wizards");
			File iconsFolder = p.getFolder("icons").getLocation().toFile();
			iconsFolder.mkdir();

			List<String> fileNames = new ArrayList<String>();
			fileNames.add("Activity.png");
			fileNames.add("End.png");
			fileNames.add("Start.png");
			fileNames.add("FlowGraph.png");
			if (features.contains(CONTAINERS)) {
				fileNames.add("Swimlane.png");
			}

			for (String fileName : fileNames) {

				File trgFile = p.getFolder("icons").getFile(fileName).getLocation().toFile();
				try {
					trgFile.createNewFile();
				} catch (IOException e1) {
					e1.printStackTrace();
				}
				try (
						InputStream is= FileLocator.openStream(sourceBundle, new Path("/example-icons/".concat(fileName)), false);
						FileOutputStream os = new FileOutputStream(trgFile);
						)
						{
					byte[] buffer = new byte[1024 * 16];
					int readLength;
					while ((readLength = is.read(buffer)) != -1) {
						os.write(buffer, 0, readLength);
					}

						} catch (IOException e) {
							e.printStackTrace();
						}
			}
			
		}
	

}
