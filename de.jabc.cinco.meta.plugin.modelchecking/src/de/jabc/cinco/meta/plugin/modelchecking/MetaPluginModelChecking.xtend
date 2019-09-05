package de.jabc.cinco.meta.plugin.modelchecking

import de.jabc.cinco.meta.plugin.CincoPlugin
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.project.GraphModelProjectTmpl
import java.util.Map
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.project.ModelCheckingProjectTmpl

class MetaPluginModelChecking extends CincoPlugin{
	
	override getProjectTemplates() {
		#[
			ModelCheckingProjectTmpl,
			GraphModelProjectTmpl
		]
	}
	
	override execute(Map<String, Object> map){
		super.execute(map)
		return "default"
	}
}