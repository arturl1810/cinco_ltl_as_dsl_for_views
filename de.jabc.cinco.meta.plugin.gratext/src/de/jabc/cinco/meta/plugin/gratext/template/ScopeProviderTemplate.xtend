package de.jabc.cinco.meta.plugin.gratext.template

import mgl.ComplexAttribute
import mgl.Edge
import mgl.ModelElement

class ScopeProviderTemplate extends AbstractGratextTemplate {

	def targetNodes(Edge edge) {
		model.resp(edge).targetNodes
	}
	
	def transformer() { fileFromTemplate(TransformerTemplate) }

	override template() '''	
		package «project.basePackage».scoping
		
		import graphmodel.IdentifiableElement
		import graphmodel.internal.InternalIdentifiableElement
		import «project.basePackage».*
		import «transformer.className»
		
		import java.util.stream.Collectors
		import java.util.stream.StreamSupport
		import org.eclipse.emf.ecore.EObject
		import org.eclipse.emf.ecore.EReference
		import org.eclipse.xtext.EcoreUtil2
		import org.eclipse.xtext.naming.QualifiedName
		import org.eclipse.xtext.scoping.IScope
		import org.eclipse.xtext.scoping.Scopes
		import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
		
		/**
		 * This class contains custom scoping description.
		 */
		class «project.targetName»ScopeProvider extends AbstractDeclarativeScopeProvider {
			
			val transformer = new «transformer.classSimpleName»
			
			override getScope(EObject context, EReference reference) {
				getScope(context, reference.name) ?: super.getScope(context, reference)
			}
			
			dispatch def IScope getScope(EObject element, String refName) {
				null
			}
			
			«model.instance.scopeMethodTmpl ?: ""»
			«model.nonAbstractNodes.map[scopeMethodTmpl].filterNull.join('\n')»
			«model.nonAbstractEdges.map[scopeMethodTmpl].filterNull.join('\n')»
			«model.userDefinedTypes.map[scopeMethodTmpl].filterNull.join('\n')»
			
			def scopeForContents(EObject obj, Class<?>... types) {
				obj.root.contents.filter(anyTypeOf(types)).toList.scope
			}
			
			def root(EObject context) {
				EcoreUtil2.getRootContainer(context)
			}
			
			def contents(EObject obj) {
				val Iterable<EObject> iterable = [obj.eAllContents]
				StreamSupport.stream(iterable.spliterator, false).collect(Collectors.toList)
			}
			
			def anyTypeOf(Class<?>... types) {
				[Object obj | types.stream.anyMatch[obj.isInstance(it)]]
			}
			
			def isInstance(Object obj, Class<?> type) {
				if (type.package.name == "«project.basePackage»") {
					type.isInstance(obj)
				}
				if (obj instanceof InternalIdentifiableElement) {
					val ime = transformer.toBaseInternal(obj)
					type.isInstance(ime.element)
				}
			}
			
			def <T extends EObject> IScope scope(Iterable<? extends T> elements) {
				Scopes.scopeFor(elements, [ QualifiedName::create((it as InternalIdentifiableElement).id) ], IScope.NULLSCOPE)
			}
		}
	'''
	
	def scopeMethodTmpl(ModelElement it) {
		val modelElementRefs = model.resp(it).attributes
			.filter(ComplexAttribute)
			.filter[model.contains(type.name)]
			.filter[!model.containsUserDefinedType(type.name)]
		if (it instanceof Edge || !modelElementRefs.isEmpty) '''
			dispatch def IScope getScope(^«name» element, String refName) {
				switch refName {
					«if (it instanceof Edge) '''
					case "_targetElement": element.scopeForContents(
						«targetNodes.map[toModelType].join(',\n')» )
					'''»
					«modelElementRefs.map['''
						case "«name»": element.scopeForContents(
							«type.toModelType»
						)
					'''].join("\n")»
				}
			}
		'''
	}
	
	def toModelType(mgl.Type it)
		'''«graphmodel.package».«model.name.toLowerCase».^«name»'''
}
