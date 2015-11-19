package de.jabc.cinco.meta.plugin.gratext;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.internal.registry.Contribution;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.codegen.ecore.generator.Generator;
import org.eclipse.emf.codegen.ecore.genmodel.GenModel;
import org.eclipse.emf.codegen.ecore.genmodel.generator.GenBaseGeneratorAdapter;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.utils.BuildProperties;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.FileDescriptor;

public abstract class ProjectGenerator {

	protected Map<String, Object> ctx;
	protected IProject project;
	private IProgressMonitor monitor;
	private HashMap<Object,FileDescriptor> fileDescriptors = new HashMap<>();
	
	public ProjectGenerator() {
		
	}
	
	protected IProject createProject() {
		return createProject(false);
	}
	
	protected IProject createProject(boolean askIfDelete) {
		project = ProjectCreator.createProject(
				getSymbolicName(),
				nullsave(getSourceFolders()),
				nullsave(getReferencedProjects()),
				nullempty(getRequiredBundles()),
				nullsave(getExportedPackages()),
				nullempty(getNatures()),
				getProgressMonitor(),
				false);
		extendManifest();
		refresh(project);
		return project;
	}
	
	protected <T> List<T> nullempty(List<T> list) {
		return (list == null) ? list : (!list.isEmpty()) ? list : null;
	}
	
	protected <T> Set<T> nullempty(Set<T> set) {
		return (set == null) ? set : (!set.isEmpty()) ? set : null;
	}
	
	protected <T> Set<T> nullsave(Set<T> set) {
		return (set != null) ? set : new HashSet<T>();
	}
	
	protected <T> List<T> nullsave(List<T> list) {
		return (list != null) ? list : new ArrayList<T>();
	}
	
	protected void createBuildProperties() {
		try {
			IFile bpf = (IFile) project.findMember("build.properties");
			BuildProperties properties = BuildProperties.loadBuildProperties(bpf);
			nullsave(getBuildPropertiesBinIncludes())
				.stream().forEach(properties::appendBinExcludes);
			properties.store(bpf, getProgressMonitor());
		} catch (Exception e) {
			throw new GenerationException("Failed to create build properties", e);
		}
	}
	
//	protected void createManifest() throws IOException {
//		try {
//			File manifest = project.getLocation().append("META-INF/MANIFEST.MF").toFile();
//			BufferedWriter bufwr = new BufferedWriter(new FileWriter(manifest, true));
//			getManifestContents().stream().forEach(str -> {
//				try {
//					bufwr.append(str);
//				} catch(Exception e) {}
//			});
//			bufwr.flush();
//			bufwr.close();
//		} catch (Exception e) {
//			throw new GenerationException("Failed to create manifest", e);
//		}
//	}
	
	private IFile createFile(String name, String folderName, String content) {
		try {
			if (folderName == null || folderName.trim().isEmpty())
				return ProjectCreator.createFile(name, project, content, getProgressMonitor());
			return ProjectCreator.createFile(name, folder(folderName), content, getProgressMonitor());
		} catch (Exception e) {
			throw new GenerationException("Failed to create file " + name + " in folder " + folderName, e);
		}
	}
	
	public void execute(Map<String,Object> context) {
		init(ctx = context);
		createProject();
		createBuildProperties();
		createFiles(new FileCreator());
		BundleRegistry.INSTANCE.addBundle(project.getName(), false);
	}
	
	protected void extendManifest() {
		final StringBuilder content = new StringBuilder();
		List<String> extensions = nullsave(getManifestExtensions());
		if (!extensions.isEmpty()) {
			for (Iterator<String> it = extensions.iterator(); it.hasNext();)
				content.append(it.next() + (it.hasNext() ? ",\n" : "\n"));
			IFile manifest = project.getFolder("META-INF").getFile("MANIFEST.MF");
			if (manifest.exists()) try {
				InputStream stream = new ByteArrayInputStream(content.toString().getBytes(manifest.getCharset()));
				manifest.appendContents(stream, true, false, getProgressMonitor());
			} catch (UnsupportedEncodingException | CoreException e) {
				e.printStackTrace();
			}
		}
	}
	
	protected abstract void init(Map<String,Object> context);
	
	protected abstract void createFiles(FileCreator creator);

	protected abstract List<String> getNatures();
	
	protected abstract String getSymbolicName();
	
	protected abstract List<String> getBuildPropertiesBinIncludes();
	
	protected abstract List<String> getExportedPackages();
	
	protected abstract List<String> getManifestExtensions();
	
	protected abstract Map<String, String> getPackages();
	
	protected abstract List<IProject> getReferencedProjects();
	
	protected abstract Set<String> getRequiredBundles();
	
//	protected abstract SrcFile[] getSourceFiles(String srcFolder, String pkg);
	
	protected abstract List<String> getSourceFolders();
	
	
	protected IProgressMonitor getProgressMonitor() {
		if (monitor == null)
			monitor = new NullProgressMonitor();
		return monitor;
	}
	
	public Map<String, Object> getContext() {
		return ctx;
	}
	
	public FileDescriptor getFileDescriptor(Object key) {
		return fileDescriptors.get(key);
	}
	
	public void refresh(IProject project) {
		try {
			project.refreshLocal(IResource.DEPTH_INFINITE, getProgressMonitor());
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	protected List<String> list(String... strs) {
		return Arrays.asList(strs);
	}
	
	protected List<IFile> getFiles(String fileExtension) {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), fileExtension, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
	    ArrayList<IFile> files = new ArrayList<>();
	    IResource[] members = null;
	    try {
	    	members = container.members();
	    } catch(CoreException e) {
	    	e.printStackTrace();
	    }
	    if (members != null)
			Arrays.stream(members).forEach(mbr -> {
			   if (recurse && mbr instanceof IContainer)
				   files.addAll(getFiles((IContainer) mbr, fileExtension, recurse));
			   else if (mbr instanceof IFile && !!mbr.isDerived()) {
				   IFile file = (IFile) mbr;
				   if (fileExtension.equals(file.getFileExtension()))
						   files.add(file);
			   }
		   });
		return files;
	}
	
	protected IFolder folder(String folderName) throws CoreException {
		if (folderName == null || folderName.trim().isEmpty())
			return project.getFolder(project.getProjectRelativePath());
		return createResource(project.getFolder(folderName));
	}
	
	/**
	 * recursively create resources.
	 * taken from here: https://www.eclipse.org/forums/index.php/mv/msg/91710/282873/#msg_282873
	 * 
	 */
	protected <T extends IResource> T createResource(T resource) throws CoreException {
		if (resource == null || resource.exists())
			return resource;
		if (!resource.getParent().exists())
			createResource(resource.getParent());
		
		switch (resource.getType()) {
		case IResource.FILE :
			((IFile) resource).create(new ByteArrayInputStream(new byte[0]),
					true, getProgressMonitor());
			break;
		case IResource.FOLDER :
			((IFolder) resource).create(IResource.NONE, true, monitor);
			break;
		case IResource.PROJECT :
			((IProject) resource).create(getProgressMonitor());
			((IProject) resource).open(getProgressMonitor());
			break;
		}
		return resource;
	}
	
	
//	protected class SrcFile {
//		
//		String fileName;
//		Class<?> templateClass;
//		
//		public SrcFile(String fileName, Class<?> templateClass) {
//			this.fileName = fileName;
//			this.templateClass = templateClass;
//		}
//	}
	
	protected class FileCreator {
		
//		public IFile createFile(FileDescriptor file) {
//			IFile f = createFile(file.getName(), file.getProjectRelativeDir(), file.getContent());
//			return f;
//		}
		
		public TemplateBasedFileCreator createFile(String fileName) {
			return new TemplateBasedFileCreator(null, null, fileName);
		}
		
		public SrcFileCreator inSrcFolder(String srcFolder) {
			return new SrcFileCreator(srcFolder);
		}
	}
	
	protected class SrcFileCreator {
		
		String srcFolder;
		
		public SrcFileCreator(String srcFolder) {
			this.srcFolder = srcFolder;
		}
		
		public PkgRelatedSrcFileCreator inPackage(String pkg) {
			return new PkgRelatedSrcFileCreator(srcFolder, pkg);
		}
	}
	
	protected class PkgRelatedSrcFileCreator {
		
		String srcFolder;
		String pkg;
		
		public PkgRelatedSrcFileCreator(String srcFolder, String pkg) {
			this.srcFolder = srcFolder;
			this.pkg = pkg;
		}
		
		public TemplateBasedFileCreator createFile(String fileName) {
			return new TemplateBasedFileCreator(srcFolder, pkg, fileName);
		}
	}
	
	protected class TemplateBasedFileCreator {
		
		String srcFolder;
		String pkg;
		String fileName;
		
		public TemplateBasedFileCreator(String srcFolder, String pkg, String fileName) {
			this.srcFolder = srcFolder;
			this.pkg = pkg;
			this.fileName = fileName;
		}
		
		public IFile withContent(String content) {
			IFile file = null;
			if (srcFolder == null || srcFolder.trim().isEmpty())
				if (pkg == null || pkg.trim().isEmpty())
					file = createFile(fileName, null, content);
				else file = createFile(fileName, pkg.replace(".", "/"), content);
			else if (pkg == null || pkg.trim().isEmpty())
				file = createFile(fileName, srcFolder, content);
			else file = createFile(fileName, srcFolder + "/" + pkg.replace(".", "/"), content);
			fileDescriptors.put(fileName,
				new FileDescriptor(file)
					.setName(fileName)
					.setSourceFolder(srcFolder)
					.setPackage(pkg)
					.setContent(content));
			return file;
		}
		
		public IFile withContent(Class<?> templateClass, Object ctx) {
			try {
				Method method = templateClass.getMethod("create", ctx.getClass());
				method.setAccessible(true);
				String content = method.invoke(templateClass.newInstance(), ctx).toString();
				IFile file = withContent(content);
				fileDescriptors.put(templateClass,
						new FileDescriptor(file)
							.setName(fileName)
							.setSourceFolder(srcFolder)
							.setPackage(pkg)
							.setContent(content));
				return file;
			} catch(Exception e) {
				e.printStackTrace();
				throw new GenerationException("Failed to generate file from template " + templateClass, e);
			}
		}
	}
	
	
	
}
