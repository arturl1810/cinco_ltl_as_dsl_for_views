package de.jabc.cinco.meta.plugin.gratext.template

class BackupGeneratorTemplate extends AbstractGratextTemplate {
		
def fileExtension() {
	graphmodel.fileExtension
}
		
override template()
'''
package «project.basePackage».generator

import de.jabc.cinco.meta.plugin.gratext.runtime.generator.BackupGenerator

class «model.name»BackupGenerator extends BackupGenerator<«model.basePackage».«model.acronym».«model.name»> {
	
	override fileExtension() {
		"«fileExtension»«backupFileSuffix»"
	}
}
'''
}