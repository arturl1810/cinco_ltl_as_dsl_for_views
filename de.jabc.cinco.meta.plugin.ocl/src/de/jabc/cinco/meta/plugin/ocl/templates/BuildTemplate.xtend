package de.jabc.cinco.meta.plugin.ocl.templates

class BuildTemplate {
	def create()
	'''
source.. = src/
output.. = bin/
bin.includes = plugin.xml,\
               META-INF/,\
               .
	
	'''
}