package de.jabc.cinco.meta.plugin

import de.jabc.cinco.meta.core.BundleRegistry
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin
import java.util.Map
import mgl.GraphModel

abstract class CincoPlugin extends CincoMetaContext implements IMetaPlugin {
	
	def Iterable<Class<? extends ProjectTemplate>> getProjectTemplates()
	
	override execute(Map<String, Object> map) {
		try {
			this.model = map.get("graphModel") as GraphModel
			this.run
			return "default"
		} catch(Exception e) {
			e.printStackTrace
			return "error"
		}
	}
	
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