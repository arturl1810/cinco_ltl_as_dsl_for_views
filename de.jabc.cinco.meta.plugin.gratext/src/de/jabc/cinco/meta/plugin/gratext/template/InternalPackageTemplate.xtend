package de.jabc.cinco.meta.plugin.gratext.template

class InternalPackageTemplate extends AbstractGratextTemplate {
	
	override template() '''
		package internal
		interface InternalPackage extends graphmodel.internal.InternalPackage {}
	'''
}