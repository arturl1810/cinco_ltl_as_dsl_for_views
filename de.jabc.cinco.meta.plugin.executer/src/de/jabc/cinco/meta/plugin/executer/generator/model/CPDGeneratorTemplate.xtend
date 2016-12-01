package de.jabc.cinco.meta.plugin.executer.generator.model

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate

class CPDGeneratorTemplate extends MainTemplate{
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override create(ExecutableGraphmodel eg)
	'''
	cincoProduct «eg.graphModel.name»ESTool {

		mgl "model/«eg.graphModel.name»ES.mgl"

	}
	'''
	
	override fileName() {
		return super.graphmodel.graphModel.name+"ESTool.cpd"
	}
	
}