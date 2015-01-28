package de.jabc.cinco.meta.plugin.template

class BuildTemplate {
	def create()'''
bin.includes = META-INF/,\
               plugin.xml,\.
	'''
}