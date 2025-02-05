package de.jabc.cinco.meta.plugin.dsl

import java.util.Set
import org.eclipse.core.resources.IContainer
import org.eclipse.core.runtime.Path
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.eclipse.core.runtime.Platform.getBundle

abstract class FileContainerDescription<T extends IContainer> extends ProjectResourceDescription<T> {
	
	@Accessors boolean deleteIfExistent = false
	@Accessors Set<FileDescription> files = newHashSet
	@Accessors Set<Pair<String,String>> filesFromBundles = newHashSet
	@Accessors Set<Pair<String,String>> filesFromProjects = newHashSet
	@Accessors Set<FolderDescription> folders = newLinkedHashSet
	
	new(String name) { super(name) }
	
	def createFiles() {
		filesFromBundles
			.map[getBundle(key)?.findEntries(value, "*", true)]
			.map[toList].flatten
			.forEach[
				getIResource.createFile(
					file.substring(file.lastIndexOf('/') + 1), openStream)
			]
		
		filesFromProjects
			.map[workspaceRoot?.getProject(key)?.getFolder(value).files]
			.flatten
			.forEach[
				copy(getIResource.fullPath.append(name), true, null)
			]
			
		files.forEach[create(this)]
	}
	
	
	def createFolders() {
		folders.forEach[ foldDesc |
			if (foldDesc.isDeleteIfExistent) {
				IResource.getFolder(new Path(foldDesc.name)) => [ folder |
					if (folder?.exists) folder.delete(true, monitor)
				]
			}
			foldDesc.create(this)
		]
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
