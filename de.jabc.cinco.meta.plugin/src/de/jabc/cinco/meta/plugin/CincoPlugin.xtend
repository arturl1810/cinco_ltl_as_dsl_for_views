package de.jabc.cinco.meta.plugin

import de.jabc.cinco.meta.core.BundleRegistry
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import org.eclipse.core.resources.IProject

abstract class CincoPlugin extends CincoMetaContext {
	
	def Iterable<Class<? extends ProjectTemplate>> getProjectTemplates()
	
	def void run() {
		projectTemplates.forEach[createProject]
	}
	
	def createProject(Class<? extends ProjectTemplate> tmplClass) {
		val project = tmplClass.newInstance.withContext(this).createProject
		project?.register
		return project
	}
	
	def register(IProject project) {
		if (project != null)
			BundleRegistry.INSTANCE.addBundle(project.name, false)
	}
}