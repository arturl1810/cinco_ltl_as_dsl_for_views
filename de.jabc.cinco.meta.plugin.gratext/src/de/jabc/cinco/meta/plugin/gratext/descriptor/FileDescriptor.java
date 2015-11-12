package de.jabc.cinco.meta.plugin.gratext.descriptor;

import org.eclipse.core.resources.IFile;


public class FileDescriptor {

	
	public FileDescriptor(IFile obj) {
		this.obj = obj;
		setName(obj.getName());
	}
	
	private IFile obj;
	public IFile resource() {
		if (obj == null)
			throw new IllegalStateException("Resource has not been created, yet.");
		return obj;
	}
	
	private String name;
	public String getName() {
		return name;
	}
	public FileDescriptor setName(String name) {
		this.name = name;
		int index = name.lastIndexOf(".");
		if (index > -1)
			setNameWithoutExtension(name.substring(0, index));
		return this;
	}
	
	private String nameWithoutExtension;
	public String getNameWithoutExtension() {
		return nameWithoutExtension;
	}
	public FileDescriptor setNameWithoutExtension(String name) {
		this.nameWithoutExtension = name;
		return this;
	}
	
	private String sourceFolder;
	public String getSourceFolder() {
		return sourceFolder;
	}
	public FileDescriptor setSourceFolder(String folder) {
		this.sourceFolder = folder;
		if (getSrcFolderRelativeDir() != null) {
			setProjectRelativeDir(getSourceFolder() + "/" + getSrcFolderRelativeDir());
		}
		return this;
	}
	
	private String pkg;
	public String getPackage() {
		return pkg;
	}
	public FileDescriptor setPackage(String pkg) {
		this.pkg = pkg;
		setSrcFolderRelativeDir(pkg.replace(".","/"));
		if (getSourceFolder() != null) {
			setProjectRelativeDir(getSourceFolder() + "/" + getSrcFolderRelativeDir());
		}
		return this;
	}
	
	private String absoluteDir;
	public String getAbsoluteDir() {
		return absoluteDir;
	}
	public FileDescriptor setAbsoluteDir(String dir) {
		this.absoluteDir = dir;
		return this;
	}
	
	private String srcFolderRelativeDir;
	public String getSrcFolderRelativeDir() {
		return srcFolderRelativeDir;
	}
	public FileDescriptor setSrcFolderRelativeDir(String dir) {
		this.srcFolderRelativeDir = dir;
		return this;
	}
	
	private String projectRelativeDir;
	public String getProjectRelativeDir() {
		return projectRelativeDir;
	}
	public FileDescriptor setProjectRelativeDir(String dir) {
		this.projectRelativeDir = dir;
		return this;
	}
	
	private Class<?> templateClass;
	public Class<?> getTemplateClass() {
		return templateClass;
	}
	public FileDescriptor setTemplateClass(Class<?> templateClass) {
		this.templateClass = templateClass;
		return this;
	}
	
	private String content;
	public String getContent() {
		return content;
	}
	public FileDescriptor setContent(String content) {
		this.content = content;
		return this;
	}
	
}
