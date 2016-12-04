package de.jabc.cinco.meta.plugin.pyro.templates.presentation.resources.components.modals.graph

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable

class ModelingCanvasProperties implements Templateable{
	
	override create(TemplateContainer tc)
	'''
		buttonText=Create GraphModel
		modalTitle=Create a new GraphModel
		NameLabel=Name
		GraphLabel=Graph
		create=Create
		cancel=Cancel
		
		graphView=Canvas
		map=Map
		propertiesView= Properties View
		
		buttonRemove=Remove
		buttonRotate=Rotate
		buttonResize=Scale
	'''	
}