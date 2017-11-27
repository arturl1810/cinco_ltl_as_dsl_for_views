package de.jabc.cinco.meta.plugin.gratext

import de.jabc.cinco.meta.plugin.CincoPlugin
import project.GratextProjectTmpl
import project.GratextUiProjectTmpl

class GratextPlugin extends CincoPlugin {
	
	override getProjectTemplates() {
		#[
			GratextProjectTmpl,
			GratextUiProjectTmpl
		]
	}
}