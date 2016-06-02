package de.jabc.cinco.meta.plugin.gratext.template

class GratextResourceTemplate extends AbstractGratextTemplate {
		
override template()
'''
package «project.basePackage»

import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource
import «project.basePackage».generator.«model.name»ModelGenerator
import org.eclipse.emf.ecore.resource.Resource

class «model.name»GratextResource extends GratextResource {
	
	override generateModel(Resource resource) {
		new «model.name»ModelGenerator().doGenerate(resource)
	}
	
}
'''
}