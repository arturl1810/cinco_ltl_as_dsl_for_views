package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import graphmodel.GraphModel

interface ModelBuilder<M extends GraphModel> {
	
	def abstract void buildModel(M model, CheckableModel<?, ?> checkableModel, boolean withSelection)
}
