package de.jabc.cinco.meta.plugin.behavior

import de.jabc.cinco.meta.plugin.CincoPlugin
import de.jabc.cinco.meta.plugin.behavior.templates.project.ProjectTemplate

class Plugin extends CincoPlugin{
	
	override getProjectTemplates() {#[
		ProjectTemplate
	]}
}
