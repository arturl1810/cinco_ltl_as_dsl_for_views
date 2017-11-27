package file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class InternalPackageTmpl extends FileTemplate {
	
	override getTargetFileName() '''InternalPackage.xtend'''
	
	override template() '''
		package internal
		
		/*
		 * This is a workaround for a bug. Xtext does not recognize the 'internal'
		 * package in GraphModel.ecore and tends to generate code against the class
		 * package.InternalPackage instead of graphmodel.internal.InternalPackage
		 */
		
		interface InternalPackage extends graphmodel.internal.InternalPackage {}
	'''
	
}