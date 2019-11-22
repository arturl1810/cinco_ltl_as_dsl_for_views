package de.jabc.cinco.meta.plugin

import de.jabc.cinco.meta.core.BundleRegistry
import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import java.util.Map
import java.util.Set
import mgl.GraphModel
import org.eclipse.core.resources.IProject
import productDefinition.CincoProduct
import productDefinition.Annotation

abstract class CincoPlugin extends CincoMetaContext implements IMetaPlugin, ICPDMetaPlugin {
	
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
	
	override execute(Annotation anno, Set<GraphModel> mglList, CincoProduct cpd, IProject project) {
		try {
			this.cpd = cpd
			this.run
		} catch(Exception e) {
			e.printStackTrace
		}
	}
	
	def void run() {
		projectTemplates.forEach[createProject]
	}

	def createProject(Class<? extends ProjectTemplate> tmplClass) {
		val project = tmplClass.newInstance.withContext(this).createProject
		project?.register
//		project?.buildIncremental
		return project
	}

	def register(IProject project) {
		if (project != null)
			BundleRegistry.INSTANCE.addBundle(project.name, false)
	}
}
