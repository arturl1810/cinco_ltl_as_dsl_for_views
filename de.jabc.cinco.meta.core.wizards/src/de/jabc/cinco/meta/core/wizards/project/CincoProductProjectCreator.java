package de.jabc.cinco.meta.core.wizards.project;

import static de.jabc.cinco.meta.core.wizards.project.ExampleFeature.*;

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
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ISetSelectionTarget;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.utils.BuildProperties;
import de.jabc.cinco.meta.core.utils.EclipseFileUtils;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.core.wizards.templates.CincoProductWizardTemplates;

public class CincoProductProjectCreator {
	
	private final String projectName;
	private final String packageName;
	private final String mglModelName;
	private final String productName;
	private final boolean createExample;
	private final Set<ExampleFeature> features;
	
	public CincoProductProjectCreator(String projectName, String packageName, String mglModelName, String productName, boolean createExample, Set<ExampleFeature> features) {
		this.projectName = projectName;
		this.packageName = packageName;
		this.mglModelName = (mglModelName.endsWith(".mgl")) ? mglModelName.split("\\.")[0] : mglModelName;
		this.productName = productName;
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
		
				modifyBuildProperties(project,monitor);

		try {
			IFolder modelFolder = project.getFolder("model");
			createResource(modelFolder, monitor);
			IFile mglModelFile = modelFolder.getFile(mglModelName.concat(".mgl"));
			IFile styleModelFile = modelFolder.getFile(mglModelName.concat(".style"));
			IFile cpdModelFile = modelFolder.getFile(productName.concat(".cpd"));
			if (!createExample) {
				CharSequence mglCode = CincoProductWizardTemplates.generateSomeGraphMGL(mglModelName, packageName);
				EclipseFileUtils.writeToFile(mglModelFile, mglCode);
				
				CharSequence styleCode = CincoProductWizardTemplates.generateSomeGraphStyle();
				EclipseFileUtils.writeToFile(styleModelFile, styleCode);

				CharSequence cpdCode = CincoProductWizardTemplates.generateSomeGraphCPD(mglModelName, packageName);
				EclipseFileUtils.writeToFile(cpdModelFile, cpdCode);
				
				
			}
			else {
				CharSequence mglCode = CincoProductWizardTemplates.generateFlowGraphMGL(mglModelName, packageName, projectName, features);
				EclipseFileUtils.writeToFile(mglModelFile, mglCode);
				
				CharSequence styleCode = CincoProductWizardTemplates.generateFlowGraphStyle(packageName, features);
				EclipseFileUtils.writeToFile(styleModelFile, styleCode);

				CharSequence cpdCode = CincoProductWizardTemplates.generateFlowGraphCPD(mglModelName, packageName, features);
				EclipseFileUtils.writeToFile(cpdModelFile, cpdCode);
				
				IFile readmeFile = project.getFile("README.txt");
				CharSequence readmeCode = CincoProductWizardTemplates.generateReadme(mglModelName, packageName, projectName, features);
				EclipseFileUtils.writeToFile(readmeFile, readmeCode);

				if (features.contains(APPEARANCE_PROVIDER)) {
					IFolder appearanceFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/appearance");
					createResource(appearanceFolder, monitor); 
					IFile appearanceProviderFile = appearanceFolder.getFile("SimpleArrowAppearance.java");
					CharSequence appearanceProviderCode = CincoProductWizardTemplates.generateAppearanceProvider(mglModelName, packageName);
					EclipseFileUtils.writeToFile(appearanceProviderFile, appearanceProviderCode);
				}
				if (features.contains(CODE_GENERATOR)) {
					IFolder codegenFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/codegen");
					createResource(codegenFolder, monitor);
					IFile codegenFile = codegenFolder.getFile("Generate.java");
					CharSequence codegenCode = CincoProductWizardTemplates.generateCodeGenerator(mglModelName, packageName);
					EclipseFileUtils.writeToFile(codegenFile, codegenCode);
				}
				if (features.contains(CUSTOM_ACTION)) {
					IFolder customActionFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/action");
					createResource(customActionFolder, monitor);
					IFile customActionFile = customActionFolder.getFile("ShortestPathToEnd.java");
					CharSequence customActionCode = CincoProductWizardTemplates.generateCustomAction(mglModelName, packageName);
					EclipseFileUtils.writeToFile(customActionFile, customActionCode);
				}
				if (features.contains(ICONS)){
					copyIcons(project);
				}
				if (features.contains(PRODUCT_BRANDING)){
					copyBranding(project);
				}
				if (features.contains(PRIME_REFERENCES)) {
					IFile externalLibraryEcoreFile = modelFolder.getFile("ExternalLibrary.ecore");
					CharSequence externalLibraryEcoreCode = CincoProductWizardTemplates.generatePrimeRefEcore(mglModelName, packageName);
					EclipseFileUtils.writeToFile(externalLibraryEcoreFile, externalLibraryEcoreCode);

					IFile externalLibraryGenmodelFile = modelFolder.getFile("ExternalLibrary.genmodel");
					CharSequence externalLibraryGenmodelCode = CincoProductWizardTemplates.generatePrimeRefGenmodel(
							mglModelName, packageName, projectName, ProjectCreator.makeSymbolicName(projectName));
					EclipseFileUtils.writeToFile(externalLibraryGenmodelFile, externalLibraryGenmodelCode);
				}
				if (features.contains(POST_CREATE_HOOKS) || features.contains(TRANSFORMATION_API)) {
					IFolder hooksFolder = project.getFolder("src/" + packageName.replaceAll("\\.", "/") + "/hooks");
					createResource(hooksFolder, monitor); 
					if (features.contains(POST_CREATE_HOOKS)) {
						IFile appearanceProviderFile = hooksFolder.getFile("RandomActivityName.java");
						CharSequence randomNameHookCode = CincoProductWizardTemplates.generateRandomActivityNameHook(mglModelName, packageName);
						EclipseFileUtils.writeToFile(appearanceProviderFile, randomNameHookCode);
					}
					if (features.contains(TRANSFORMATION_API)) {
						IFile appearanceProviderFile = hooksFolder.getFile("InitializeFlowGraphModel.java");
						CharSequence initFlowGraphHookCode = CincoProductWizardTemplates.generateInitFlowGraphHook(mglModelName, packageName);
						EclipseFileUtils.writeToFile(appearanceProviderFile, initFlowGraphHookCode);
						
					}
				}
			}

			project.refreshLocal(IResource.DEPTH_INFINITE, monitor);

			IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
			ISetSelectionTarget projectExplorerView = (ISetSelectionTarget)page.findView(IPageLayout.ID_PROJECT_EXPLORER);
			// FIXME: projectExplorerView is null if current perspective does not contain a "Project Explorer" view
			projectExplorerView.selectReveal(new StructuredSelection(cpdModelFile));


		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	private void modifyBuildProperties(IProject project,IProgressMonitor monitor) {
		IFile buildPropertiesFile = (IFile)project.findMember("build.properties");
		
		try {
			BuildProperties buildProperties = BuildProperties.loadBuildProperties(buildPropertiesFile);	
			buildProperties.appendBinIncludes("icons/");
			buildProperties.appendBinIncludes("plugin.xml");
			buildProperties.appendBinIncludes("plugin.properties");
			buildProperties.appendSource("src-gen/");
			buildProperties.appendSource("src-gen/");
			IResource srcFolder = project.findMember("src/");
			if(srcFolder!=null && srcFolder.exists())
				buildProperties.appendSource("src/");
			buildProperties.appendBinIncludes("resources-gen/");
			buildProperties.store(buildPropertiesFile, monitor);
		} catch (IOException | CoreException e) {
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
		if (features.contains(CODE_GENERATOR)) {
			bundles.add("de.jabc.cinco.meta.plugin.generator.runtime");
		}
		return bundles;
	}

	private List<String> getSrcFolders() {
		List<String> folders = new ArrayList<String>();
		
		Set<ExampleFeature> codeFeatures = EnumSet.of(APPEARANCE_PROVIDER, CODE_GENERATOR, CUSTOM_ACTION, POST_CREATE_HOOKS, TRANSFORMATION_API);
		
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
	
	private void copyFiles(IProject p, String sourceFolderName, String targetFolderName, List<String> fileNames) {
			Bundle sourceBundle = Platform.getBundle("de.jabc.cinco.meta.core.wizards");
			File targetFolder = p.getFolder(targetFolderName).getLocation().toFile();
			targetFolder.mkdir();

			for (String fileName : fileNames) {

				File trgFile = p.getFolder(targetFolderName).getFile(fileName).getLocation().toFile();
				try {
					trgFile.createNewFile();
				} catch (IOException e1) {
					e1.printStackTrace();
				}
				try (
					InputStream is= FileLocator.openStream(sourceBundle, new Path(sourceFolderName.concat("/").concat(fileName)), false);
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

	private void copyIcons(IProject p) {
			List<String> fileNames = new ArrayList<String>();
			fileNames.add("Activity.png");
			fileNames.add("End.png");
			fileNames.add("Start.png");
			fileNames.add("FlowGraph.png");
			if (features.contains(CONTAINERS)) {
				fileNames.add("Swimlane.png");
			}
			
			copyFiles(p, "example-icons", "icons", fileNames);
		}

	private void copyBranding(IProject p) {
			List<String> fileNames = new ArrayList<String>();
			fileNames.add("Icon16.png");
			fileNames.add("Icon32.png");
			fileNames.add("Icon48.png");
			fileNames.add("Icon64.png");
			fileNames.add("Icon128.png");
			fileNames.add("splash.bmp");
			
			copyFiles(p, "example-branding", "branding", fileNames);
		}
	

}
