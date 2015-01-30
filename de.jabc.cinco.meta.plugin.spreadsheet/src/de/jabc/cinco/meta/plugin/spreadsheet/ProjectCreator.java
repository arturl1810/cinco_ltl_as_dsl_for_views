package de.jabc.cinco.meta.plugin.spreadsheet;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.eclipse.core.internal.runtime.InternalPlatform;
import org.eclipse.core.resources.ICommand;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.SubProgressMonitor;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.pde.core.project.IBundleProjectDescription;
import org.eclipse.pde.core.project.IBundleProjectService;
import org.eclipse.ui.PlatformUI;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

import de.jabc.cinco.meta.plugin.template.BuildTemplate;

@SuppressWarnings("restriction")
public class ProjectCreator {

	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor, boolean askIfDel, String pluginContent) {
		 
		return createProject(projectName, srcFolders,
				 referencedProjects, requiredBundles,
				exportedPackages,  additionalNatures,  progressMonitor, null, askIfDel,pluginContent);
	}
	
	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor, boolean askIfDel) {
		 
		return createProject(projectName, srcFolders,
				 referencedProjects, requiredBundles,
				exportedPackages,  additionalNatures,  progressMonitor, null, askIfDel,null);
	}
	
	public static IProject createProject(final String projectName, final List<String> srcFolders,
			final List<IProject> referencedProjects, final Set<String> requiredBundles,
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor) {
		 
		return createProject(projectName, srcFolders,
				 referencedProjects, requiredBundles,
				exportedPackages,  additionalNatures,  progressMonitor, null, true,null);
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
			final List<String> exportedPackages, final List<String> additionalNatures, final IProgressMonitor progressMonitor, final List<String> cleanDirs, boolean askIfDelete, String pluginContent) {
		
		IProject project = null;
		try {
			progressMonitor.beginTask("", 10);
			progressMonitor.subTask("Creating project " + projectName);
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
							project.delete(true, true, new SubProgressMonitor(progressMonitor, 1));
						} else {
							for (String s : cleanDirs) {
								IFolder f = project.getFolder(s);
								if (f.exists()) {
									f.delete(true, progressMonitor);
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
				project.create(projectDescription, new SubProgressMonitor(progressMonitor, 1));
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

			project.open(new SubProgressMonitor(progressMonitor, 1));
			project.setDescription(projectDescription, new SubProgressMonitor(progressMonitor, 1));

			if (srcFolders != null) {
				Collections.reverse(srcFolders);
				for (final String src : srcFolders) {
					final IFolder srcContainer = project.getFolder(src);
					if (!srcContainer.exists()) {
						srcContainer.create(false, true,new SubProgressMonitor(progressMonitor, 1));
						@SuppressWarnings("unused")
						IPackageFragment pack = javaProject.getPackageFragmentRoot(srcContainer).createPackageFragment(projectName, false, null);
					}
					final IClasspathEntry srcClasspathEntry = JavaCore
							.newSourceEntry(srcContainer.getFullPath());
					classpathEntries.add(0, srcClasspathEntry);
				}
			}
			classpathEntries
					.add(JavaCore
							.newContainerEntry(new Path(
									"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.7")));
			classpathEntries.add(JavaCore.newContainerEntry(new Path("org.eclipse.pde.core.requiredPlugins")));

			javaProject.setRawClasspath(classpathEntries.toArray(new IClasspathEntry[classpathEntries.size()]),
					new SubProgressMonitor(progressMonitor, 1));

			javaProject.setOutputLocation(new Path("/" + projectName + "/bin"), new SubProgressMonitor(progressMonitor,
					1));
			if(pluginContent != null){
				createPlugin(projectName, pluginContent, progressMonitor, project);
				
			}
			createManifest(projectName, requiredBundles, exportedPackages, progressMonitor, project);
			createBuildProps(progressMonitor, project, srcFolders);
			
			
		}
		catch (final Exception exception) {
			exception.printStackTrace();
		}
		finally {
			progressMonitor.done();
		}

		return project;
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
	
	private static void createPlugin(final String projectName, final String content, final IProgressMonitor progressMonitor, final IProject project)
	throws CoreException {
		
		final StringBuilder plugiContent = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		plugiContent.append("<?eclipse version=\"3.4\"?>\n");
		plugiContent.append("<plugin>\n\n");
		plugiContent.append(content);
		plugiContent.append("\n</plugin>\n");
		
		createFile("plugin.xml", project.getFile("plugin.xml").getParent(), plugiContent.toString(), progressMonitor);
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
		maniContent.append("Bundle-RequiredExecutionEnvironment: JavaSE-1.7\r\n");

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
		bpContent.append(new BuildTemplate().create());
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
		progressMonitor.worked(1);

		return file;
	}
	
	public static String getProjectSymbolicName(IProject project) {
		BundleContext bc = InternalPlatform.getDefault().getBundleContext();
		@SuppressWarnings("rawtypes")
		ServiceReference ref = bc.getServiceReference(IBundleProjectService.class.getName());
		@SuppressWarnings("unchecked")
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
	
}
