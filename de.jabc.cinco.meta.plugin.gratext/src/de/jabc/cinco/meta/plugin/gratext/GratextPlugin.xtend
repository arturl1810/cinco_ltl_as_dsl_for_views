package de.jabc.cinco.meta.plugin.gratext

import de.jabc.cinco.meta.plugin.CincoPlugin
import de.jabc.cinco.meta.plugin.gratext.tmpl.project.GratextProjectTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.project.GratextUiProjectTmpl

class GratextPlugin extends CincoPlugin {
	
	override getProjectTemplates() {#[
		GratextProjectTmpl,
		GratextUiProjectTmpl
	]}
}