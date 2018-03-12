package de.jabc.cinco.meta.plugin.dsl

import java.util.Set
import org.eclipse.core.resources.IContainer
import org.eclipse.xtend.lib.annotations.Accessors

abstract class FileContainerDescription<T extends IContainer> extends ProjectResourceDescription<T> {
	
	@Accessors boolean deleteIfExistent = false
	@Accessors Set<FileDescription> files = newHashSet
	@Accessors Set<FolderDescription> folders = newLinkedHashSet
	
	new(String name) { super(name) }
	
	def createFiles() {
		files.forEach[create(this)]
	}
	
	def createFolders() {
		folders.forEach[System.err.println(" > create folder: " + name) create(this)]
	}
	
	def Iterable<FileContainerDescription<?>> getHierarchy() {
		#[this] + (parent?.hierarchy ?: #[])
	}
	
	def add(FileDescription file) {
		files.add(file)
		file.setParent(this)
	}
	
	def add(FolderDescription folder) {
		folders.add(folder)
		folder.setParent(this)
	}
}
