package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class BuildTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "build.properties"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	source.. = src/
	output.. = bin/
	bin.includes = plugin.xml,\
	               META-INF/,\
	               .
	
	'''
	
}