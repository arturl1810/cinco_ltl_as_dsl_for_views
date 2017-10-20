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

import mgl.GraphModel;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.utils.BuildProperties;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.plugin.gratext.descriptor.FileDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ModelDescriptorRegistry;
import de.jabc.cinco.meta.plugin.gratext.descriptor.ProjectDescriptor;
import de.jabc.cinco.meta.runtime.xapi.FileExtension;
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension;

public abstract class ProjectGenerator {

	private static WorkspaceExtension workspace = new WorkspaceExtension();
	
	protected Map<String, Object> ctx;
	
	public GraphModel model;
	private GraphModelDescriptor modelDesc;
	public IProject project;
	private ProjectDescriptor projectDesc;
	
	private IProgressMonitor monitor;
	protected HashMap<Object,FileDescriptor> fileDescriptors = new HashMap<>();
	
	public ProjectGenerator() {}
	
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
				getDirectoriesToBeCleaned(),
				false);
		extendManifest();
		refresh(project);
		return project;
	}
	
	public GraphModelDescriptor getModelDescriptor() {
		if (model == null) 
			model = (GraphModel) getContext().get("graphModel");
		
		if (modelDesc == null)
			modelDesc = ModelDescriptorRegistry.INSTANCE.get(model);
		
		if (modelDesc == null) {
			modelDesc = new GraphModelDescriptor(model);
			modelDesc.setBasePackage(model.getPackage());
			ModelDescriptorRegistry.INSTANCE.add(modelDesc);
		}
		
		return modelDesc;
	}
	
	public IProject getModelProject() {
		return ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(model.eResource().getURI().toPlatformString(true))).getProject();
	}
	
	public String getModelProjectSymbolicName() {
		IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(model.eResource().getURI().toPlatformString(true)));
		return (res != null)
				? ProjectCreator.getProjectSymbolicName(res.getProject())
				: model.getPackage();
	}
	
	public abstract String getProjectAcronym();

	public abstract String getProjectSuffix();
	
	public ProjectDescriptor getProjectDescriptor() {
		String basePkg = getModelDescriptor().getBasePackage();
		if (getProjectAcronym() != null && !getProjectAcronym().trim().isEmpty())
			basePkg += "." + getProjectAcronym();
		if (projectDesc == null || (projectDesc.instance() == null && project != null)) {
			String targetName = getModelDescriptor().getName();
			if (getProjectSuffix() != null && !getProjectSuffix().trim().isEmpty()) 
				targetName += getProjectSuffix();
			projectDesc = new ProjectDescriptor(project)
				.setSymbolicName(basePkg)
				.setTargetName(targetName);
			projectDesc.setBasePackage(basePkg)
				.setAcronym(getProjectAcronym());
		}
		return projectDesc;
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
				.stream().forEach(properties::appendBinIncludes);
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
	
	public IProject execute(Map<String,Object> context) {
		init(ctx = context);
		createProject();
		createBuildProperties();
		createFiles();
		BundleRegistry.INSTANCE.addBundle(project.getName(), false);
		return project;
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
	
	protected abstract void createFiles();
	
	protected abstract List<String> getDirectoriesToBeCleaned();

	protected abstract List<String> getNatures();
	
	protected abstract List<String> getBuildPropertiesBinIncludes();
	
	protected abstract List<String> getExportedPackages();
	
	protected abstract List<String> getManifestExtensions();
	
	protected abstract Map<String, String> getPackages();
	
	protected abstract List<IProject> getReferencedProjects();
	
	protected abstract Set<String> getRequiredBundles();
	
//	protected abstract SrcFile[] getSourceFiles(String srcFolder, String pkg);
	
	protected abstract List<String> getSourceFolders();
	
	protected String getSymbolicName() {
		return getProjectDescriptor().getSymbolicName();
	}
	
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
	
	protected <T extends Object> List<T> list(T... objs) {
		return Arrays.asList(objs);
	}
	
	protected <T extends Object> Set<T> set(T... objs) {
		return new HashSet<>(list(objs));
	}
	
	protected List<IFile> getWorkspaceFiles(String extension) {
		return workspace.getFiles(workspace.getWorkspaceRoot(), f -> !f.isDerived() && extension.equals(f.getFileExtension()));
	}
		
	public TemplateBasedFileCreator createFile(String fileName) {
		return new TemplateBasedFileCreator(null, null, fileName);
	}
	
	public SrcFileCreator inSrcFolder(String srcFolder) {
		return new SrcFileCreator(srcFolder);
	}
	
	private IFile createFile(String name, String folderName, String content) {
		try {
			IContainer container = (folderName == null || folderName.trim().isEmpty())
				? project
				: folder(folderName);
			return workspace
//				.withProgressMonitor(getProgressMonitor())
				.createFile(container, name, content);
		} catch (Exception e) {
			throw new GenerationException("Failed to create file " + name + " in folder " + folderName, e);
		}
	}
	
	protected IFolder folder(String folderName) throws CoreException {
		if (folderName == null || folderName.trim().isEmpty())
			return project.getFolder(project.getProjectRelativePath());
		return workspace.create(project.getFolder(folderName));
	}
	
	protected class SrcFileCreator {
		
		String srcFolder;
		
		public SrcFileCreator(String srcFolder) {
			this.srcFolder = srcFolder;
		}
		
		public PkgRelatedSrcFileCreator inPackage(String pkg) {
			return new PkgRelatedSrcFileCreator(srcFolder, pkg);
		}

		public TemplateBasedFileCreator createFile(String fileName) {
			return new TemplateBasedFileCreator(srcFolder, null, fileName);
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
		
		public TemplateBasedFileCreator inSrcFolder(String srcFolder) {
			this.srcFolder = srcFolder;
			return this;
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
		
		public IFile withContent(Class<?> templateClass) {
			try {
				Method method = templateClass.getMethod("create", ProjectGenerator.class);
				method.setAccessible(true);
				String content = method.invoke(templateClass.newInstance(), ProjectGenerator.this).toString();
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
