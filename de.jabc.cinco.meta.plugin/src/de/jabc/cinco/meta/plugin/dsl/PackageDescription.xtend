package de.jabc.cinco.meta.plugin.dsl

import org.eclipse.core.resources.IFolder

class PackageDescription extends FileContainerDescription<IFolder> {
	
	new(String name) { super(name) }
	
	override create() {
		IResource = parent.IResource.createFolder(name.replace(".", "/"))
		createFiles
		return IResource
	}
	
}
