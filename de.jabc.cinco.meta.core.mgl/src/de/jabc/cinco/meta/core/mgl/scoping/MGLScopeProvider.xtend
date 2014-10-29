/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.scoping

import mgl.ReferencedAttribute
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.emf.ecore.EObject
import mgl.Import

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class MGLScopeProvider extends AbstractDeclarativeScopeProvider {
	
	def IScope scope_ReferencedAttribute_feature(ReferencedAttribute attr, EReference ref){
		
		val scope = getScope(attr.referencedType.type,ref)
		return scope
	}
	
}
