package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import java.util.HashMap
import mgl.GraphModel

import static de.jabc.cinco.meta.core.utils.MGLUtil.*
class FactoryGeneratorExtensions {
	
	
	// FIXME: Switching over GraphModel / ModelElement should not be necessary. Introduce a common super class InternalIdentifiableElement instead?
	static def createFactory(GraphModel graphmodel, HashMap<String,ElementEClasses> elmClasses)'''
		package «graphmodel.package».factory
		
		import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
		
		import «graphmodel.package».«graphmodel.name.toLowerCase».«graphmodel.name.toLowerCase.toFirstUpper»Package
		import «graphmodel.package».«graphmodel.name.toLowerCase».impl.«graphmodel.name»Impl
		import «graphmodel.package».«graphmodel.name.toLowerCase».impl.«graphmodel.name.toLowerCase.toFirstUpper»FactoryImpl
		import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalFactory
		import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalPackage
		
		import graphmodel.internal.InternalModelElement
		import graphmodel.internal.InternalGraphModel
		import graphmodel.ModelElement
		import graphmodel.IdentifiableElement
		import graphmodel.GraphModel
		
		import org.eclipse.emf.ecore.EClass
		import org.eclipse.emf.ecore.EPackage
		import org.eclipse.emf.ecore.plugin.EcorePlugin
		
		class «graphmodel.name»Factory extends «graphmodel.name.toLowerCase.toFirstUpper»FactoryImpl {
			
«««			Can't call this method as extension...
			final extension InternalFactory = InternalFactory.eINSTANCE
			public static «graphmodel.name»Factory eINSTANCE = «graphmodel.name»Factory.init
			
			static def «graphmodel.name»Factory init() {
				try {
					EPackage::Registry.INSTANCE.getEFactory(«graphmodel.name.toLowerCase.toFirstUpper»Package.eNS_URI) as «graphmodel.name»Factory
				}
				catch (Exception exception) {
					EcorePlugin.INSTANCE.log(exception);
				}
				new «graphmodel.name»Factory
			}
			
			«elmClasses.values.genericCreateMethod»
			
			«elmClasses.values.specificCreateMethods»
			
			private def <T extends IdentifiableElement> setInternal(T elm, IdentifiableElement internal) {
				elm => [
					ID = generateUUID
					switch elm {
						GraphModel: elm.internalElement = internal as InternalGraphModel
						ModelElement: elm.internalElement = internal as InternalModelElement
					}
				]
			}

			«getPostCreateHooks(graphmodel)»
		
«««			private static def setUID(«IdentifiableElement.name» me) {
«««				«EcoreUtil.name».setID(me, «EcoreUtil.name».generateUUID);
«««			}
		}
	'''
	
	static def genericCreateMethod(Iterable<ElementEClasses> ecls) '''
		override create(EClass eClass) {
			switch eClass.classifierID {
				«ecls.map['''case «mainEClass.classifierID»: create«modelElement.name»'''].join('\n')»
				default: super.create(eClass)
			}
		}
	'''
	
	static def specificCreateMethods(Iterable<ElementEClasses> ecls) {
		ecls.map[modelElement].map['''
			override create«name»() {
				val n = super.create«name»
				n => [ internal = createInternal«name» ]
				«postCreate(it, "n")»
				n
			}
			
			def create«name»(InternalModelElement ime) {
				val n = super.create«name»
				n => [ internal = ime ]
				«postCreate(it, "n")»
				n
			}
«««			override def create«ecl.modelElement.name»(){
«««				val «ecl.mainEClass.name.toLowerCase» = «model.name.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«ecl.mainEClass.name»
«««				val «ecl.internalEClass.name.toLowerCase» = InternalFactory.eINSTANCE.create«ecl.internalEClass.name»
«««				«ecl.mainEClass.name.toLowerCase».setInternalElement(«ecl.internalEClass.name.toLowerCase»);
«««				«ecl.mainEClass.name.toLowerCase».setUID();
«««				
«««				return «ecl.mainEClass.name.toLowerCase»
«««			}
		'''].join
		
	}
}