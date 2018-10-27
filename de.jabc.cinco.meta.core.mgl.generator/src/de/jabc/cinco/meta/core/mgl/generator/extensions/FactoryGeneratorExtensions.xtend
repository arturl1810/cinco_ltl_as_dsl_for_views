package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import java.io.IOException
import java.util.Map
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import mgl.Type
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*
import mgl.ModelElement
import mgl.GraphicalModelElement
import mgl.UserDefinedType

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
		import graphmodel.internal.InternalNode
		import graphmodel.internal.InternalEdge
		import graphmodel.internal.InternalType
		import graphmodel.internal.InternalIdentifiableElement
		import graphmodel.ModelElement
		import graphmodel.IdentifiableElement
		import graphmodel.GraphModel
		import graphmodel.Type
		
		import org.eclipse.emf.ecore.EClass
		import org.eclipse.emf.ecore.EPackage
		import org.eclipse.emf.ecore.plugin.EcorePlugin
		
		class «graphmodel.name»Factory extends «graphmodel.name.toLowerCase.toFirstUpper»FactoryImpl {
			
«««			Can't call this method as extension...
			final extension InternalFactory = InternalFactory.eINSTANCE
			public static «graphmodel.name»Factory eINSTANCE = «graphmodel.name»Factory.init
			
			extension «WorkbenchExtension.name» = new «WorkbenchExtension.name»
			
			static def «graphmodel.name»Factory init() {
				try {
					val fct = EPackage::Registry.INSTANCE.getEFactory(«graphmodel.name.toLowerCase.toFirstUpper»Package.eNS_URI) as «graphmodel.name»Factory
					if (fct != null)
						return fct as «graphmodel.name»Factory
				}
				catch (Exception exception) {
					EcorePlugin.INSTANCE.log(exception);
				}
				new «graphmodel.name»Factory
			}
			
			«elmClasses.values.specificCreateMethods»
			
			private def <T extends IdentifiableElement> setInternal(T elm, InternalIdentifiableElement internal) {
				elm => [
					if (id.isNullOrEmpty)
						ID = generateUUID
					switch elm {
						GraphModel: elm.internalElement = internal as InternalGraphModel
						ModelElement: elm.internalElement = internal as InternalModelElement
						Type: elm.internalElement = internal as InternalType
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

				res.getContents().add(graph.internalElement);
				
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
	
	static def specificCreateMethods(Iterable<ElementEClasses> ecls) {
		ecls.map[modelElement].filter(typeof(GraphModel)).map[specificCreateMethod].join + 
		ecls.map[modelElement].filter(typeof(Node)).map[specificCreateMethod].join + 
		ecls.map[modelElement].filter(typeof(Edge)).map[specificCreateMethod].join +
		ecls.map[modelElement].filter(typeof(UserDefinedType)).map[specificCreateMethod].join
	}
	
	dispatch static def specificCreateMethod(GraphModel it)'''
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
					setID(ID + "_INTERNAL")
					«IF !(it instanceof Type)»
						container = parent
					«ENDIF»
					eAdapters.add(new «graphModel.package».adapter.«name»EContentAdapter)
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
	
	dispatch static def specificCreateMethod(Node it)'''
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
					setID(ID + "_INTERNAL")
					«IF !(it instanceof Type)»
						container = parent
					«ENDIF»
					container = parent
					eAdapters.add(new «graphModel.package».adapter.«name»EContentAdapter)
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
	
		dispatch static def specificCreateMethod(Edge it)'''
		def create«name»(String ID, InternalModelElement ime, InternalNode source, InternalNode target, boolean hook) {
			super.create«name» => [ 
				setID(ID)
				internal = ime ?: createInternal«name» => [
					(it as InternalEdge).set_sourceElement(source)
					(it as InternalEdge).set_targetElement(target)
					setID(ID + "_INTERNAL")
					eAdapters.add(new «graphModel.package».adapter.«name»EContentAdapter)
				]
				«postCreateHook»
			]
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook will be triggered.
		 */
		def create«name»(String ID, InternalNode source, InternalNode target){
			create«name»(ID,null,source,target,true)
		}
		
		/**
		 * This method creates an «name» with generated id. Post create hook will be triggered.
		 */
		def create«name»(InternalNode source, InternalNode target){
			create«name»(generateUUID,null,source,target,true)
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 */
		def create«name»(String ID){
			create«name»(ID,null,null,null,false)
		}
		
		/**
		 * This method creates an «name» with a generated id. Post create hook won't be triggered.
		 */
		override create«name»() {
			create«name»(generateUUID)
		}
		'''
		
		dispatch static def specificCreateMethod(UserDefinedType it)'''
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 *
		 * @param ID: The id for the new element
		 * @param ime: The internal model element {@link graphmodel.internal.InternalModelElement}
		 * @param parent: The parent element of the newly created element. Needed if a post create hook accesses the parent
		 * element of the created element
		 * @param ID: Indicates, if the post create hook should be executed
		 */
		def create«name»(String ID, InternalModelElement ime, boolean hook){
			super.create«name» => [ 
				setID(ID)
				internal = ime ?: createInternal«name» => [
					setID(ID + "_INTERNAL")
					eAdapters.add(new «graphModel.package».adapter.«name»EContentAdapter)
				]
				«IF (!annotations.filter[name == "postCreate"].isEmpty)»
					postCreates
				«ENDIF»
«««				«postCreateHook»
			]
			
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 */
		def create«name»(String ID){
			create«name»(ID,null,false)
		}
		
		/**
		 * This method creates an «name» with the given id. Post create hook won't be triggered.
		 */
		def create«name»(InternalModelElement ime) {
			create«name»(generateUUID,ime,false)
		}
		
		override create«name»() {
			create«name»(generateUUID)
		}
		'''
}