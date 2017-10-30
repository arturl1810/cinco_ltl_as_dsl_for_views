package de.jabc.cinco.meta.plugin.gratext.template

import mgl.ComplexAttribute
import mgl.Edge
import mgl.ModelElement

class ScopeProviderTemplate extends AbstractGratextTemplate {

	def targetNodes(Edge edge) {
		model.resp(edge).targetNodes
	}

	override template() '''	
		package «project.basePackage».scoping
		
		import graphmodel.internal.InternalIdentifiableElement
		import «project.basePackage».*
		
		import org.eclipse.emf.ecore.EObject
		import org.eclipse.emf.ecore.EReference
		import org.eclipse.xtext.naming.QualifiedName
		import org.eclipse.xtext.scoping.IScope
		import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
		
		import static extension org.eclipse.xtext.EcoreUtil2.getRootContainer
		import static extension org.eclipse.xtext.scoping.Scopes.scopeFor
		
		/**
		 * This class contains custom scoping description.
		 */
		class «project.targetName»ScopeProvider extends AbstractDeclarativeScopeProvider {
			
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
				obj.rootContainer.contents
					.filter(anyTypeOf(types))
					.filter(InternalIdentifiableElement)
					.toScope
			}
			
			def getContents(EObject obj) {
				val Iterable<EObject> iterable = [obj.eAllContents]
				return iterable
			}
			
			def anyTypeOf(Class<?>... types) {
				[Object obj | types.stream.anyMatch[isInstance(obj)]]
			}
			
			def IScope toScope(Iterable<InternalIdentifiableElement> elements) {
				scopeFor(elements, [QualifiedName::create(id)], IScope.NULLSCOPE)
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
		'''«graphmodel.package».«model.name.toLowerCase».internal.^Internal«name»'''
}
