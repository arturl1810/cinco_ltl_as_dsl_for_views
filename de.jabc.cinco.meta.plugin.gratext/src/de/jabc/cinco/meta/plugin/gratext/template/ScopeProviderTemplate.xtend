package de.jabc.cinco.meta.plugin.gratext.template

class ScopeProviderTemplate extends AbstractGratextTemplate {


override template()
'''	
package «project.basePackage».scoping

import graphmodel.Node
import «project.basePackage».*
import java.util.ArrayList
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

	override getScope(EObject context, EReference reference) {
		«FOR edge:model.nonAbstractEdges»
		if (context instanceof «edge.name») { 
				if (reference.name.equals("targetElement")) {
					val root = EcoreUtil2.getRootContainer(context)
	        		val candidates = new ArrayList<Node>
	        		«FOR node:model.resp(edge).getTargetNodes»
	        		candidates.addAll(EcoreUtil2.getAllContentsOfType(root, «node.name»))
	        		«ENDFOR»
	        		return Scopes.scopeFor(candidates, [ QualifiedName::create(it.id) ], IScope.NULLSCOPE)
        		}
		}
		«ENDFOR»
		super.getScope(context, reference)
	}
}
'''
}