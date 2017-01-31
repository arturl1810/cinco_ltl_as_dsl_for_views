package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import graphmodel.IdentifiableElement
import java.util.HashMap
import mgl.GraphModel
import org.eclipse.emf.ecore.util.EcoreUtil

class FactoryGeneratorExtensions {
	static def createFactory(GraphModel graphmodel, HashMap<String,ElementEClasses> elmClasses)'''
	package «graphmodel.package».factory
	import «graphmodel.package».«graphmodel.name.toLowerCase».«graphmodel.name.toLowerCase.toFirstUpper»Factory
	import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalFactory
	
	class «graphmodel.name»Factory{
		«FOR e: elmClasses.values»
		«e.factoryMethod(graphmodel)»
		«ENDFOR»
		
		private static def setUID(«IdentifiableElement.name» me) {
			«EcoreUtil.name».setID(me, «EcoreUtil.name».generateUUID);
		}
	}
	
	'''
	
	static def factoryMethod(ElementEClasses ecl,GraphModel model)'''
	static def create«ecl.modelElement.name»(){
		val «ecl.mainEClass.name.toLowerCase» = «model.name.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«ecl.mainEClass.name»
		val «ecl.internalEClass.name.toLowerCase» = InternalFactory.eINSTANCE.create«ecl.internalEClass.name»
		«ecl.mainEClass.name.toLowerCase».setInternalElement(«ecl.internalEClass.name.toLowerCase»);
		«ecl.mainEClass.name.toLowerCase».setUID();
		
		return «ecl.mainEClass.name.toLowerCase»
	}
	'''
}