package de.jabc.cinco.meta.plugin.primeviewer

import de.jabc.cinco.meta.plugin.CincoPlugin
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.project.PrimeViewerProjectTmpl

class PrimeViewerPlugin extends CincoPlugin {
	
	override getProjectTemplates() {#[
		PrimeViewerProjectTmpl
	]}
	
}