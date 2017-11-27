package de.jabc.cinco.meta.plugin.dsl

import de.jabc.cinco.meta.plugin.CincoMetaContext
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.core.resources.IResource

abstract class ProjectResourceDescription<T extends IResource> extends CincoMetaContext {
	
	@Accessors String name
	@Accessors String symbolicName
	@Accessors ProjectDescription project
	@Accessors FileContainerDescription<?> parent
	@Accessors(PUBLIC_GETTER, PROTECTED_SETTER) T iResource
	
	new(String name) {
		setName(name)
	}
	
	protected def T create()
	
	def T create(FileContainerDescription<?> parent) {
		this.withParent(parent).create
	}
	
	def void setName(String name) {
		this.name = name
		if (name != null) {
			var it = name.replaceAll("[^a-zA-Z0-9_\\-\\.]", "_")
			if (endsWith("."))
				it = substring(0, lastIndexOf('.')) + "_"
			if (startsWith(".")) 
				it = "_" + substring(1);
			symbolicName = it
		}
	}
	
	def withParent(FileContainerDescription<?> parent) {
		withContext(parent)
//		println('''Pass «parent.class.simpleName»:«parent.getName» as parent to «class.simpleName»:«getName»''')
		setParent(parent)
		if (parent instanceof ProjectDescription) {
//			println('''Pass «parent.class.simpleName»:«parent.getName» as project to «class.simpleName»:«getName»''')
			setProject(parent as ProjectDescription)
		}
		else {
//			println('''Pass «parent.getProject?.class?.simpleName»:«parent.getProject?.getName» as project to «class.simpleName»:«getName»''')
			setProject(parent.getProject)
		}
		return this
	}
}