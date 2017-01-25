package de.jabc.cinco.meta.core.mgl.generator.extensions

import mgl.GraphModel
import java.util.HashMap
import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses

class FactoryGeneratorExtensions {
	static def createFactory(GraphModel graphmodel, HashMap<String,ElementEClasses> elmClasses)'''
	package «graphmodel.package».factory
	import «graphmodel.package».«graphmodel.name.toLowerCase».«graphmodel.name.toLowerCase.toFirstUpper»Factory
	import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalFactory
	
	class «graphmodel.name»Factory{
		«FOR e: elmClasses.values»
		«e.factoryMethod(graphmodel)»
		«ENDFOR»
	}
	
	'''
	
	static def factoryMethod(ElementEClasses ecl,GraphModel model)'''
	static def create«ecl.modelElement.name»(){
		val «ecl.mainEClass.name.toLowerCase» = «model.name.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«ecl.mainEClass.name»
		val «ecl.internalEClass.name.toLowerCase» = InternalFactory.eINSTANCE.create«ecl.internalEClass.name»
		«ecl.mainEClass.name.toLowerCase».set«ecl.internalEClass.name»(«ecl.internalEClass.name.toLowerCase»);
		
		return «ecl.mainEClass.name.toLowerCase»
	}
	'''
}