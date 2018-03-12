package de.jabc.cinco.meta.plugin.template

import de.jabc.cinco.meta.plugin.CincoMetaContext
import de.jabc.cinco.meta.plugin.dsl.ProjectDescription
import de.jabc.cinco.meta.plugin.dsl.ProjectDescriptionLanguage

abstract class ProjectTemplate extends CincoMetaContext {
	
	protected extension ProjectDescriptionLanguage = new ProjectDescriptionLanguage
	
	ProjectDescription _projectDescription
	
	def void init() {/* override in sub classes */}
	
	def createProject() {
		init
		val desc = getProjectDescription
		System.err.println("Create project: " + desc.name)
		desc?.withContext(this).create
	}
	
	def getProjectDescription() {
		_projectDescription ?: (_projectDescription = projectDescription())
	}
	
	abstract def ProjectDescription projectDescription()
	
	abstract def String projectSuffix()
	
	protected def getProjectSuffix(Class<? extends ProjectTemplate> tmplClass) {
		tmplClass.newInstance.withContext(this).projectSuffix
	}
	
	def getBasePackage() {
		projectName
	}
	
	protected def getBasePackage(Class<? extends ProjectTemplate> tmplClass) {
		tmplClass.newInstance.withContext(this).basePackage
	}
	
	def subPackage(String suffix) {
		basePackage + suffix.withDotPrefix
	}
	
	def getProjectName() {
		model.package + projectSuffix.withDotPrefix
	}
	
	protected def getProjectName(Class<? extends ProjectTemplate> tmplClass) {
		tmplClass.newInstance.withContext(this).projectName
	}
	
	private def withDotPrefix(String name) {
		(if (!name?.startsWith('.')) '.' else '') + (name ?: '')
	}
}
