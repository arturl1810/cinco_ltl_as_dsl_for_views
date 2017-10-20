package de.jabc.cinco.meta.plugin.gratext.template

class InternalPackageTemplate extends AbstractGratextTemplate {
	
	override template() '''
		package internal
		
		/*
		 * This is a workaround for an Xtext that does not recognized the 'internal'
		 * package in GraphModel.ecore and tends to generate code against the class
		 * package.InternalPackage instead of graphmodel.internal.InternalPackage
		 */
		
		interface InternalPackage extends graphmodel.internal.InternalPackage {}
	'''
}