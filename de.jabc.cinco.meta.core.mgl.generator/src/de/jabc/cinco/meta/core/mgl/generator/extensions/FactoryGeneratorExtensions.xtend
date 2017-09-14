package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.io.IOException
import java.util.Map
import mgl.GraphModel
import mgl.ModelElement
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*

class FactoryGeneratorExtensions {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	// FIXME: Switching over GraphModel / ModelElement should not be necessary. Introduce a common super class InternalIdentifiableElement instead?
	static def createFactory(GraphModel graphmodel, Map<String,ElementEClasses> elmClasses)'''
		package «graphmodel.package».factory
		
		import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
		
		import «graphmodel.package».«graphmodel.name.toLowerCase».«graphmodel.name.toLowerCase.toFirstUpper»Package
		import «graphmodel.package».«graphmodel.name.toLowerCase».impl.«graphmodel.name»Impl
		import «graphmodel.package».«graphmodel.name.toLowerCase».impl.«graphmodel.name.toLowerCase.toFirstUpper»FactoryImpl
		import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalFactory
		import «graphmodel.package».«graphmodel.name.toLowerCase».internal.InternalPackage
		
		import «graphmodel.package».«graphmodel.name.toLowerCase».adapter.*
		
		import graphmodel.internal.InternalModelElement
		import graphmodel.internal.InternalModelElementContainer
		import graphmodel.internal.InternalGraphModel
		import graphmodel.internal.InternalContainer
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
			
«««			«elmClasses.values.genericCreateMethod»
			
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

			/**
			* This method creates a new «graphmodel.fuName» object with an underlying «Resource.name». Thus you can 
			* simply call the «graphmodel.fuName»'s save method to save your changes.
			*/
			def «graphmodel.fqBeanName» create«graphmodel.fuName»(«String.name» path, «String.name» fileName) {
				var filePath = new «Path.name»(path).append(fileName).addFileExtension("«graphmodel.name.toLowerCase»");
				var uri = «URI.name».createPlatformResourceURI(filePath.toOSString(), true);
				var res = new «ResourceSetImpl.name»().createResource(uri);
				var graph = «graphmodel.fqFactoryName».eINSTANCE.create«graphmodel.fuName»();
				
				«EcoreUtil.name».setID(graph, «EcoreUtil.name».generateUUID());

				res.getContents().add(graph);
				
				«IF graphmodel.hasPostCreateHook»
				postCreates(graph);
				«ENDIF»
				try {
					res.save(null);
				} catch («IOException.name» e) {
					e.printStackTrace();
				}

				return graph;
			}

			«getPostCreateHooks(graphmodel)»
		}
	'''
	// FIXME: the classifier IDs are in arbitrary order! they do not match those of the model elements
//	static def genericCreateMethod(Iterable<ElementEClasses> ecls) '''
//		override create(EClass eClass) {
//			switch eClass.classifierID {
//				«ecls.map['''case «mainEClass.classifierID»: create«modelElement.name»'''].join('\n')»
//				default: super.create(eClass)
//			}
//		}
//	'''
	
	static def specificCreateMethods(Iterable<ElementEClasses> ecls) {
//		ecls.forEach[println(it.modelElement)]
		ecls.map[modelElement].map[specificCreateMethod].join
	}
	
	static def specificCreateMethod(ModelElement it)'''
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 *
		 * @param ID: The id for the new element
		 * @param ime: The internal model element {@link graphmodel.internal.InternalModelElement}
		 * @param parent: The parent element of the newly created element. Needed if a post create hook accesses the parent
		 * element of the created element
		 * @param ID: Indicates, if the post create hook should be executed
		 */
		def create«name»(String ID, InternalModelElement ime, InternalModelElementContainer parent, boolean hook){
			super.create«name» => [ 
				setID(ID)
				internal = ime ?: createInternal«name» => [
					setID(generateUUID)
					«IF !(it instanceof Type)»
						container = parent
					«ENDIF»
					«IF !(it instanceof UserDefinedType)»
						eAdapters.add(new «graphModel.package».adapter.«name»EContentAdapter)
					«ENDIF»
				]
				«postCreateHook»
			]
			
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 */
		def create«name»(String ID){
			create«name»(ID,null,null,false)
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook will be triggered.
		 */
		def create«name»(InternalModelElementContainer parent){
			create«name»(generateUUID,null,parent,true)
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook will be triggered.
		 */
		def create«name»(String ID, InternalModelElementContainer parent){
			create«name»(ID,null,parent,true)
		}

		def create«name»(String ID, InternalModelElement ime, InternalModelElementContainer parent){
			create«name»(ID,ime,parent,true)
		}

		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 */
		def create«name»(InternalModelElement ime) {
			create«name»(generateUUID,ime,null,false)
		}
		
		override create«name»() {
			create«name»(generateUUID)
		}
		'''
	
}