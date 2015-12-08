package de.jabc.cinco.meta.plugin.gratext.template

import mgl.Edge

class ScopeProviderTemplate extends AbstractGratextTemplate {


def targetNodes(Edge edge) {
	model.resp(edge).targetNodes
}

override template()
'''	
package «project.basePackage».scoping

import graphmodel.IdentifiableElement
import «project.basePackage».*
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

«««	override getScope(EObject context, EReference reference) {
«««		«FOR edge:model.nonAbstractEdges»
«««		if (context instanceof «edge.name») { 
«««				if (reference.name.equals("targetElement")) {
«««					val root = EcoreUtil2.getRootContainer(context)
«««	        		val candidates = new ArrayList<Node>
«««	        		«FOR node:model.resp(edge).getTargetNodes»
«««	        		candidates.addAll(EcoreUtil2.getAllContentsOfType(root, «node.name»))
«««	        		«ENDFOR»
«««	        		return Scopes.scopeFor(candidates, [ QualifiedName::create(it.id) ], IScope.NULLSCOPE)
«««        		}
«««		}
«««		«ENDFOR»
«««		super.getScope(context, reference)
«««	}
	
	override getScope(EObject context, EReference reference) {
		switch reference.name {
			case "targetElement": switch context {
				«model.nonAbstractEdges.map[
				'''
				^«name»: context.root.scopeForContents(
						«targetNodes.map[name].join(',\n')» )
				'''	
				].join('\n')»
				default: super.getScope(context, reference)
			}
			default: super.getScope(context, reference)
		}
	}
	
	def root(EObject context) {
		EcoreUtil2.getRootContainer(context)
	}
	
	def scopeForContents(EObject obj, Class<?>... types) {
		obj.contents.filter(anyTypeOf(types)).toList.scope
	}
	
	def contents(EObject obj) {
		val Iterable<EObject> iterable = [obj.eAllContents]
		StreamSupport.stream(iterable.spliterator, false).collect(Collectors.toList)
	}
	
	def anyTypeOf(Class<?>... types) {
		[Object obj | types.stream.anyMatch[isAssignableFrom(obj.class)]]
	}
	
	def <T extends EObject> IScope scope(Iterable<? extends T> elements) {
		Scopes.scopeFor(elements, [ QualifiedName::create((it as IdentifiableElement).id) ], IScope.NULLSCOPE)
	}
}
'''
}