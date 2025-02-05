package de.jabc.cinco.meta.core.utils.projects;

import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.jar.Manifest;

import org.eclipse.core.internal.runtime.InternalPlatform;
import org.eclipse.core.resources.ICommand;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.SubProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.pde.core.project.IBundleProjectDescription;
import org.eclipse.pde.core.project.IBundleProjectService;
import org.eclipse.ui.PlatformUI;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

import de.jabc.cinco.meta.core.utils.CincoUtil;
import mgl.GraphModel;
import mgl.Node;
import mgl.NodeContainer;

public class ProjectCreator {

	private static final List<String> DEFAULT_SOURCE = Arrays.asList(new String[] {"src", "src-gen"});
	private static final List<String> DEFAULT_CLEAN = Arrays.asList(new String[] {"src-gen"}); 
	
	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor, boolean askIfDel) {
		 
		return createProject(projectName, srcFolders,
				 referencedProjects, requiredBundles,
				exportedPackages,  additionalNatures,  progressMonitor, null, askIfDel);
	}
	
	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor) {
		 
		return createProject(projectName, srcFolders,
				 referencedProjects, requiredBundles,
				exportedPackages,  additionalNatures,  progressMonitor, null, true);
	}
	
	
	/**
	 * Creates a new Java Plugin-Project.
	 * 
	 * @param projectName Name of new project
	 * @param srcFolders Source folders which will be created
	 * @param referencedProjects Referenced Projects
	 * @param requiredBundles The required bundles
	 * @param exportedPackages Packages which will be exported
	 * @param additionalNatures Additional Natures. Defaults are java nature and plug-in nature
	 * @param progressMonitor Progress monitor
	 * @return New project
	 */
	
	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor, final List<String> cleanDirs, boolean askIfDelete) {
			IProgressMonitor localProgressMonitor = progressMonitor;
			if(localProgressMonitor==null)
				localProgressMonitor = new NullProgressMonitor();
		IProject project = null;
		try {
			//progressMonitor.beginTask("", 10);
			//progressMonitor.subTask("Creating project " + projectName);
			final IWorkspace workspace = ResourcesPlugin.getWorkspace();
			project = workspace.getRoot().getProject(projectName);

			// Clean up any old project information.
			if (project.exists()) {
				final boolean[] result = new boolean[1];
				result[0] = true;
				if (askIfDelete) {
					PlatformUI.getWorkbench().getDisplay().syncExec(new Runnable() {
						public void run() {
							result[0] = MessageDialog.openQuestion(null, "Do you want to overwrite the project "
									+ projectName, "Note that everything inside the project '" + projectName
									+ "' will be deleted if you confirm this dialog.");
						}
					});
				}

					if (result[0]) {
						if (cleanDirs == null) {
							project.delete(true, true, null);
						} else {
							for (String s : cleanDirs) {
								IFolder f = project.getFolder(s);
								if (f.exists()) {
									f.delete(true, localProgressMonitor);
								}
							}
						}
					}
				else
					return null;
			}

			final IJavaProject javaProject = JavaCore.create(project);
			final IProjectDescription projectDescription = ResourcesPlugin.getWorkspace().newProjectDescription(
					projectName);
			projectDescription.setLocation(null);
			if (!project.exists())
				project.create(projectDescription, new SubProgressMonitor(localProgressMonitor, 1));
			final List<IClasspathEntry> classpathEntries = new ArrayList<IClasspathEntry>();
			if (referencedProjects != null && referencedProjects.size() != 0) {
				projectDescription.setReferencedProjects(referencedProjects.toArray(new IProject[referencedProjects
				                                                                                 .size()]));
				for (final IProject referencedProject : referencedProjects) {
					final IClasspathEntry referencedProjectClasspathEntry = JavaCore.newProjectEntry(referencedProject
							.getFullPath());
					classpathEntries.add(referencedProjectClasspathEntry);
				}
			}
			
			if (additionalNatures != null) {
				String[] natures = new String[additionalNatures.size()+2];
				for (int i = 0; i < additionalNatures.size(); i++) {
					natures[i] = additionalNatures.get(i);
				}
				natures[additionalNatures.size()] = JavaCore.NATURE_ID;
				natures[additionalNatures.size()+1] = "org.eclipse.pde.PluginNature";
				projectDescription.setNatureIds(natures);
			} else {
				projectDescription.setNatureIds(new String[] {JavaCore.NATURE_ID, "org.eclipse.pde.PluginNature"});
			}

			final ICommand java = projectDescription.newCommand();
			java.setBuilderName(JavaCore.BUILDER_ID);

			final ICommand manifest = projectDescription.newCommand();
			manifest.setBuilderName("org.eclipse.pde.ManifestBuilder");

			final ICommand schema = projectDescription.newCommand();
			schema.setBuilderName("org.eclipse.pde.SchemaBuilder");

			projectDescription.setBuildSpec(new ICommand[] { java, manifest, schema });

			project.open(new SubProgressMonitor(localProgressMonitor, 1));
			
			project.setDescription(projectDescription, new SubProgressMonitor(localProgressMonitor, 1));
			

			if (srcFolders != null) {
				Collections.reverse(srcFolders);
				for (final String src : srcFolders) {
					final IFolder srcContainer = project.getFolder(src);
					if (!srcContainer.exists()) {
						srcContainer.create(false, true,new SubProgressMonitor(localProgressMonitor, 1));
					}
					final IClasspathEntry srcClasspathEntry = JavaCore
							.newSourceEntry(srcContainer.getFullPath());
					classpathEntries.add(0, srcClasspathEntry);
				}
			}
			classpathEntries
					.add(JavaCore
							.newContainerEntry(new Path(
									"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8")));
			classpathEntries.add(JavaCore.newContainerEntry(new Path("org.eclipse.pde.core.requiredPlugins")));

			javaProject.setRawClasspath(classpathEntries.toArray(new IClasspathEntry[classpathEntries.size()]),
					new SubProgressMonitor(localProgressMonitor, 1));
			

			javaProject.setOutputLocation(new Path("/" + projectName + "/bin"), new SubProgressMonitor(localProgressMonitor,
					1));
			createManifest(projectName, requiredBundles, exportedPackages, localProgressMonitor, project);
			createBuildProps(localProgressMonitor, project, srcFolders);
		}
		catch (final Exception exception) {
			exception.printStackTrace();
		}
		finally {
			//progressMonitor.done();
		}

		return project;
	}
	
	/**This method creates an IProject containing the Java and Plugin nature.
	 * Per default, the src and src-gen folder is created as well a default Manifest
	 * file.
	 * @param projectName
	 * @return Create plugin project
	 */
	public static IProject createDefaultPluginProject(String projectName, Set<String> reqBundles) {
		IProject p = createProject(projectName, 
				DEFAULT_SOURCE,
				Collections.emptyList(), 
				reqBundles, 
				Collections.emptyList(), 
				Collections.emptyList(), 
				null, DEFAULT_CLEAN, 
				false);
		return p;
	}
	
	/**This method creates an IProject containing the Java and Plugin nature.
	 * Per default, the src and src-gen folder is created as well a Manifest file.
	 * The manifest contains the required bundles and exported packages.
	 * file.
	 * @param projectName
	 * @param reqBundles List of bundle id, which are required for the new project
	 * @param exportPackage List of package names, which should be exported
	 * @return Create plugin project
	 */
	public static IProject createDefaultPluginProject(String projectName, Set<String> reqBundles, List<String> exportPackage) {
		IProject p = createProject(projectName, 
				DEFAULT_SOURCE,
				Collections.emptyList(), 
				reqBundles, 
				exportPackage, 
				Collections.emptyList(), 
				null, DEFAULT_CLEAN, 
				false);
		return p;
	}
	
	
	/**
	 * converts a project name that might contain special characters into
	 * a valid Bundle-SymbolicName by replacing all invalid characters
	 * by the underscore
	 * 
	 */
	public static String makeSymbolicName(String projectName) {
		String symbolicName = projectName.replaceAll("[^a-zA-Z0-9_\\-\\.]", "_");
		// . is allowed in general, but not at the end
		if (symbolicName.endsWith(".")) {
			symbolicName = symbolicName.substring(0, symbolicName.lastIndexOf('.')) + "_";
		}
		// also not at the beginning
		if (symbolicName.startsWith(".")) {
			symbolicName = "_" + symbolicName.substring(1);
		}
		return symbolicName;
	}
	
	public static void addRequiredBundle(IProject p, Set<Bundle> bundles) throws IOException, CoreException {
		IFile file = p.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest;
		if (file.exists()) {
			manifest = new Manifest(file.getContents());
			String reqBundle = manifest.getMainAttributes().getValue("Require-Bundle");
			
			if (reqBundle == null) {
				reqBundle = new String();
			}
			
			for (Bundle b : bundles) {
				if (!reqBundle.contains(b.getSymbolicName())) 
					reqBundle += "," + b.getSymbolicName();
			}
			manifest.getMainAttributes().putValue("Require-Bundle", reqBundle);
			manifest.write(new FileOutputStream(file.getLocation().toFile()));
		}
	}
	
	public static void addRequiredBundle(IProject p, Bundle b) throws IOException, CoreException {
		IFile file = p.getFolder("META-INF").getFile("MANIFEST.MF");
		Manifest manifest;
		if (file.exists()) {
			manifest = new Manifest(file.getContents());
			String reqBundle = manifest.getMainAttributes().getValue("Require-Bundle");
			
			if (reqBundle == null) {
				reqBundle = new String();
			}
			
			reqBundle += "," + b.getSymbolicName();
			manifest.getMainAttributes().putValue("Require-Bundle", reqBundle);
			manifest.write(new FileOutputStream(file.getLocation().toFile()));
		}
	}
	
	private static void createManifest(final String projectName, final Set<String> requiredBundles,
			final List<String> exportedPackages, final IProgressMonitor progressMonitor, final IProject project)
	throws CoreException {
		final StringBuilder maniContent = new StringBuilder("Manifest-Version: 1.0\n");
		maniContent.append("Bundle-ManifestVersion: 2\n");
		maniContent.append("Bundle-Name: " + projectName + "\n");
		maniContent.append("Bundle-SymbolicName: " + makeSymbolicName(projectName) + "; singleton:=true\n");
		maniContent.append("Bundle-Version: 1.0.0\n");
		// maniContent.append("Bundle-Localization: plugin\n");
		if (requiredBundles != null) {
			maniContent.append("Require-Bundle: ");
			for (final Iterator<String> it = requiredBundles.iterator(); it
					.hasNext();) {
				String entry = it.next();
				maniContent.append(" " + entry);
				if (it.hasNext())
					maniContent.append(",\n");
				else
					maniContent.append("\n");
			}
		}

		if (exportedPackages != null && !exportedPackages.isEmpty()) {
			maniContent.append("Export-Package: " + exportedPackages.get(0));
			for (int i = 1, x = exportedPackages.size(); i < x; i++) {
				maniContent.append(",\n " + exportedPackages.get(i));
			}
			maniContent.append("\n");
		}
		maniContent.append("Bundle-RequiredExecutionEnvironment: JavaSE-1.8\r\n");

		final IFolder metaInf = project.getFolder("META-INF");
		if (!metaInf.exists())
			metaInf.create(false, true, new SubProgressMonitor(progressMonitor, 1));
		createFile("MANIFEST.MF", metaInf, maniContent.toString(), progressMonitor);
	}
	
	private static void createBuildProps(final IProgressMonitor progressMonitor, final IProject project,
			final List<String> srcFolders) {
		final StringBuilder bpContent = new StringBuilder("source.. = ");
		for (final Iterator<String> iterator = srcFolders.iterator(); iterator.hasNext();) {
			bpContent.append(iterator.next()).append('/');
			if (iterator.hasNext()) {
				bpContent.append(",");
			}
		}
		bpContent.append("\n");
		bpContent.append("bin.includes = META-INF/,.\n");
		createFile("build.properties", project, bpContent.toString(), progressMonitor);
	}
	
	public static IFile createFile(final String name, final IContainer container, final String content,
			final IProgressMonitor progressMonitor) {
		final IFile file = container.getFile(new Path(name));
		try {
			final InputStream stream = new ByteArrayInputStream(content.getBytes(file.getCharset()));
			if (file.exists()) {
				file.setContents(stream, true, true, progressMonitor);
			}
			else {
				file.create(stream, true, progressMonitor);
			}
			stream.close();
		}
		catch (final Exception e) {
			e.printStackTrace();
		}
		//progressMonitor.worked(1);

		return file;
	}
	
	public static String getProjectSymbolicName(IProject project) {
		BundleContext bc = InternalPlatform.getDefault().getBundleContext();
		ServiceReference ref = bc.getServiceReference(IBundleProjectService.class.getName());
		IBundleProjectService service = (IBundleProjectService)bc.getService(ref);
		try {
			IBundleProjectDescription bpd = service.getDescription(project);
			return bpd.getSymbolicName();
		} catch (CoreException e) {
			e.printStackTrace();
		} finally {
			bc.ungetService(ref);
		}
		return "";
	}
	/**
	 * Creates a Java Compilation Unit in a given IProject
	 * 
	 * @param project - The Project where class is to be created
	 * @param packageName - The package name of the class, may or may not exist
	 * @param className - the name of the java Class
	 * @param sourceFolder - the source folder where the package is located
	 * @param classContents - Contents of the class File
	 * @param progressMonitor
	 * @throws CoreException 
	 */
	public static void createJavaClass(IProject project,String packageName, String className, IFolder sourceFolder, String classContents,IProgressMonitor progressMonitor) throws CoreException{
			IJavaProject javaProject = JavaCore.create(project); 

			IPackageFragment pack = javaProject.getPackageFragmentRoot(sourceFolder).createPackageFragment(packageName, true, progressMonitor);
			pack.createCompilationUnit(className+".java", classContents, false, progressMonitor);
			
			project.refreshLocal(IResource.DEPTH_INFINITE, progressMonitor);
		
	}
	/**
	 * Retrieves IProject for given EMF Resource
	 * @param res - Resource
	 * @return IProject where Resource res is located, @null if res is not located in a platform resource
	 */
	public static IProject getProject(Resource res){
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		URI uri = res.getURI();
		if(uri.isPlatformResource()){
			IFile iFile = workspace.getRoot().getFile(new Path(uri.toPlatformString(true)));
			return iFile.getProject();
		}
		return null;
	}

	/**
	 * Creates a new plain Ecipse project with potentially additional natures.
	 * 
	 * @param projectName Name of new project
	 * @param additionalNatures Additional Natures.
	 * @param progressMonitor Progress monitor
	 * @return New project
	 */
	
	public static IProject createPlainProject(final String projectName, final List<String> additionalNatures, final IProgressMonitor progressMonitor,  final List<String> cleanDirs, boolean askIfDelete ) {
			IProgressMonitor localProgressMonitor = progressMonitor;
			if(localProgressMonitor==null)
				localProgressMonitor = new NullProgressMonitor();
		IProject project = null;
		try {
			final IWorkspace workspace = ResourcesPlugin.getWorkspace();
			project = workspace.getRoot().getProject(projectName);
	
			// Clean up any old project information.
			if (project.exists()) {
				final boolean[] result = new boolean[1];
				result[0] = true;
				if (askIfDelete) {
					PlatformUI.getWorkbench().getDisplay().syncExec(new Runnable() {
						public void run() {
							result[0] = MessageDialog.openQuestion(null, "Do you want to overwrite the project "
									+ projectName, "Note that everything inside the project '" + projectName
									+ "' will be deleted if you confirm this dialog.");
						}
					});
				}
	
					if (result[0]) {
						if (cleanDirs == null) {
							project.delete(true, true, null);
						} else {
							for (String s : cleanDirs) {
								IFolder f = project.getFolder(s);
								if (f.exists()) {
									f.delete(true, localProgressMonitor);
								}
							}
						}
					}
				else
					return null;
			}
	
			final IProjectDescription projectDescription = ResourcesPlugin.getWorkspace().newProjectDescription(
					projectName);
			projectDescription.setLocation(null);
			if (!project.exists())
				project.create(projectDescription, new SubProgressMonitor(localProgressMonitor, 1));
			
			if (additionalNatures != null) {
				String[] natures = new String[additionalNatures.size()];
				for (int i = 0; i < additionalNatures.size(); i++) {
					natures[i] = additionalNatures.get(i);
				}				
				projectDescription.setNatureIds(natures);
			}
	
			project.open(new SubProgressMonitor(localProgressMonitor, 1));
			
			project.setDescription(projectDescription, new SubProgressMonitor(localProgressMonitor, 1));
		
		}
		catch (final Exception exception) {
			exception.printStackTrace();
		}
		finally {
			//progressMonitor.done();
		}
	
		return project;
	}
	/**
	 * Exports a Java package in the given project
	 * @param project
	 * @param packageName
	 * @return true if package successfully exported, false if package already in exported list
	 */
	public static boolean exportPackage(IProject project,String packageName) {
		IFile iManiFile= project.getFolder("META-INF").getFile("MANIFEST.MF");
		try {
			CincoUtil.refreshFiles(null, iManiFile);
			Manifest manifest = new Manifest(iManiFile.getContents());
			
			String val = manifest.getMainAttributes().getValue("Export-Package");
			if (val == null){
				val = new String("");
			} 
			
			
			if (!val.contains(packageName)){
				if (val.isEmpty())
					val = val.concat(packageName);
				else val = val.concat(","+packageName);
			
			
			manifest.getMainAttributes().putValue("Export-Package", val);
			
			manifest.write(new FileOutputStream(iManiFile.getLocation().toFile()));
			CincoUtil.refreshFiles(null, iManiFile);
			return true;
			}
			
		} catch (IOException | CoreException e) {
			e.printStackTrace();
		}
		return false;
	}
	
	public static void addAdditionalNature(IProject project, IProgressMonitor monitor, String ... additionalNatures) {
		IProgressMonitor localProgressMonitor = monitor;
		if(localProgressMonitor==null)
			localProgressMonitor = new NullProgressMonitor();
		
		try {
			final IProjectDescription projectDescription = project.getDescription();
			String[] oldNatures = projectDescription.getNatureIds();
			if (additionalNatures != null) {
				int size = additionalNatures.length + oldNatures.length;
				
				String[] natures = new String[size];
				for (int i = 0; i < additionalNatures.length; i++) {
					natures[i] = additionalNatures[i];
				}
				for (int i = additionalNatures.length;i<size;i++)
					natures[i] = oldNatures[i-additionalNatures.length];
				projectDescription.setNatureIds(natures);
			}
		
			project.setDescription(projectDescription, new SubProgressMonitor(localProgressMonitor, 1));
		} catch (CoreException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
