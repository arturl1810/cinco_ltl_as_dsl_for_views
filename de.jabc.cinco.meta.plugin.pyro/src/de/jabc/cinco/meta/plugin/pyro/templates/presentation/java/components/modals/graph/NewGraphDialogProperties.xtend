package de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable

class NewGraphDialogProperties implements Templateable{
	
	override create(TemplateContainer tc)
	'''
		buttonText=Create GraphModel
		modalTitle=Create a new GraphModel
		NameLabel=Name
		GraphLabel=GraphModel
		create=Create
		cancel=Cancel
	'''

	
}