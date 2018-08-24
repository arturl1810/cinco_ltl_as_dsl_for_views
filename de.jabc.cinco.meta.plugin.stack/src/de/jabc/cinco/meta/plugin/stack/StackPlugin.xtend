package de.jabc.cinco.meta.plugin.stack

import de.jabc.cinco.meta.plugin.stack.template.project.StackProjectTemplate
import de.jabc.cinco.meta.plugin.CincoPlugin

class StackPlugin extends CincoPlugin{
	
	override getProjectTemplates() {#[
		StackProjectTemplate
	]}
}