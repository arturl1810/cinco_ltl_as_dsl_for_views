package de.jabc.cinco.meta.plugin.placeholder

import de.jabc.cinco.meta.plugin.CincoPlugin
import de.jabc.cinco.meta.plugin.placeholder.template.project.PlaceholderProjectTemplate

class PlaceholderPlugin extends CincoPlugin{
	
	override getProjectTemplates() {	
		#[
			PlaceholderProjectTemplate	
		]}
	
}