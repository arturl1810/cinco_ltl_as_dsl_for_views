package de.jabc.cinco.meta.plugin.template

import de.jabc.cinco.meta.plugin.CincoMetaContext
import de.jabc.cinco.meta.plugin.dsl.FileContainerDescription
import de.jabc.cinco.meta.plugin.dsl.FileDescription
import de.jabc.cinco.meta.plugin.dsl.FolderDescription
import de.jabc.cinco.meta.plugin.dsl.PackageDescription
import de.jabc.cinco.meta.plugin.dsl.ProjectDescription
import org.eclipse.xtend.lib.annotations.Accessors

abstract class FileTemplate extends CincoMetaContext {
	
	@Accessors FileContainerDescription<?> parent
	@Accessors ProjectDescription project
	
	new() {/* empty constructor for instantiation via reflection */}
	
	def CharSequence getContent() {
		init
		template
	}
	
	def void init() {/* override in sub classes */}
	
	abstract def String getTargetFileName()
	
	protected def getTargetFileName(Class<? extends FileTemplate> tmplClass) {
		tmplClass.newInstance.withContext(this).targetFileName
	}
	
	def CharSequence template()
	
	def FileDescription getFileDescription() {
		new FileDescription(class)
	}
	
	def getBasePackage() {
		switch it:project {
			ProjectDescription: name
			default: package
		}
	}
	
	def getPackage() {
		switch it:parent {
			PackageDescription: name
			FolderDescription: hierarchy.filter(FolderDescription).toList.reverse.join('.')
			default: ''
		}
	}
}
