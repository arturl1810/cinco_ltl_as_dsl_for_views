package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.ComplexAttribute
import mgl.Edge
import mgl.ModelElement
import mgl.Type

class ScopeProviderTmpl extends FileTemplate {
	
//	String projectBasePackage
//	
//	new(String projectBasePackage) {
//		this.projectBasePackage = projectBasePackage
//	}
	
	override getTargetFileName() '''«model.name»GratextScopeProvider.xtend'''
	
	def scopeMethodTmpl(ModelElement me) {
		val modelElementRefs = me.allAttributes
			.filter(ComplexAttribute)
			.filter[model.containsModelElement(type.name)]
			.filter[!model.containsUserDefinedType(type.name)]
		if (me instanceof Edge || !modelElementRefs.isEmpty) '''
			dispatch def IScope getScope(^GratextInternal«me.name» element, String refName) {
				switch refName {
					«if (me instanceof Edge) '''
					case "_targetElement": element.scopeForContents(
						«me.targetNodes.map[fqInternalBeanName].join(',\n')» )
					'''»
					«modelElementRefs.map['''
						case "«name»": element.scopeForContents(
							«(#[type] + type.nonAbstractSubTypes).map[fqInternalBeanName].join(',\n')»
						)
					'''].join("\n")»
				}
			}
		'''
	}
	
	def getNonAbstractSubTypes(Type it) {
		switch it {
			ModelElement: subTypes.drop[isAbstract]
			default: #[]
		}
	}
	
	override template() '''	
		package «package»
		
		import graphmodel.internal.InternalIdentifiableElement
		import «basePackage».*
		
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
		class «model.name»GratextScopeProvider extends AbstractDeclarativeScopeProvider {
			
			override getScope(EObject context, EReference reference) {
				getScope(context, reference.name) ?: super.getScope(context, reference)
			}
			
			dispatch def IScope getScope(EObject element, String refName) {
				null
			}
			
			«model.scopeMethodTmpl ?: ""»
			
			«(model.nodes + model.edges + model.userDefinedTypes)
				.drop[isAbstract].map[scopeMethodTmpl].filterNull.join('\n')»
			
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
	
}