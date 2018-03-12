package de.jabc.cinco.meta.plugin.dsl

import java.util.List
import org.eclipse.core.resources.IFolder
import org.eclipse.xtend.lib.annotations.Accessors

class FolderDescription extends FileContainerDescription<IFolder> {

	@Accessors boolean isSourceFolder = true
	@Accessors List<PackageDescription> packages = newArrayList
	
	new(String name) { super(name) }
	
	new(FileContainerDescription<?> parent, String name) {
		this(name)
		this.parent = parent
		if (parent instanceof ProjectDescription) {
			this.project = parent
		}
	}
	
	override create() {
		IResource = (parent ?: project)?.IResource.createFolder(name)
		createFiles
		createFolders
		createPackages
		return IResource
	}
	
	def createPackages() {
		packages.forEach[withParent(this).create]
	}
	
	def setIsSourceFolder(boolean flag) {
		this => [isSourceFolder = flag]
	}
}
