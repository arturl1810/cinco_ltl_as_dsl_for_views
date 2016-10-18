package de.jabc.cinco.meta.plugin.executer.generator.model

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class CPDGeneratorTemplate {
	
	def create(ExecutableGraphmodel eg)
	'''
	cincoProduct «eg.graphModel.name» {

		mgl "model/«eg.graphModel.name».mgl"

	}
	'''
	
}