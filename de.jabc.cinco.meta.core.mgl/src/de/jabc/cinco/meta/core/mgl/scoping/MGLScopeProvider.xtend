/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.scoping

import java.net.URL
import java.util.ArrayList
import mgl.ComplexAttribute
import mgl.GraphModel
import mgl.ModelElement
import mgl.OutgoingEdgeElementConnection
import mgl.ReferencedAttribute
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.ReferencedType
import mgl.Type
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import mgl.MglPackage
import mgl.IncomingEdgeElementConnection
import mgl.GraphicalElementContainment
import mgl.ContainingElement
import de.jabc.cinco.meta.core.utils.CincoUtil

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#scoping
 * on how and when to use it 
 *
 */
class MGLScopeProvider extends AbstractDeclarativeScopeProvider {
	
	override IScope getScope(EObject eobj, EReference ref){
		if(eobj instanceof ReferencedAttribute && (ref==MglPackage.eINSTANCE.referencedEClass_Type || ref==MglPackage.eINSTANCE.referencedModelElement_Type)){
			return scope_ReferencedAttribute_feature((eobj as ReferencedAttribute),ref)}
		else if(eobj instanceof ReferencedType){
			return scope_ReferencedType_type(eobj,ref)
		}
			
		else if(eobj instanceof OutgoingEdgeElementConnection){	
			return scope_OutgoingEdgeElementConnection_connectingEdges(eobj,ref)
		}
			
		else if(eobj instanceof IncomingEdgeElementConnection){
			return scope_IncomingEdgeElementConnection_connectingEdges(eobj,ref)
		}else if(eobj instanceof ComplexAttribute){
			return scope_ComplexAttribute_type(eobj,ref)
		}
		else if(eobj instanceof GraphicalElementContainment){
			return scope_GraphicalElementContainment__types(eobj,ref)
		}
		super.getScope(eobj,ref)
	}
	
	def scope_GraphicalElementContainment__types(GraphicalElementContainment containment, EReference reference) {
		val gm = containment.containingElement.graphModel
		Scopes.scopeFor(gm.nodes)
	}
	
	
	def IScope scope_ReferencedAttribute_feature(ReferencedAttribute attr, EReference ref){
		var scope = IScope.NULLSCOPE
		
		if(attr.referencedType instanceof ReferencedEClass)
			scope = Scopes.scopeFor((attr.referencedType as ReferencedEClass)?.type.EAllStructuralFeatures)
		else
			scope = Scopes.scopeFor((attr.referencedType as ReferencedModelElement).type.attributes)
			
		return scope
	}
	
	def IScope scope_ReferencedEClass_type(ReferencedEClass refType,EReference ref){
		var scope = IScope.NULLSCOPE
			var res = null as Resource
				try{
					res = CincoUtil::getResource(refType.imprt.importURI, refType.eResource)
				}catch(Exception e){
					return null;
				}
			if(res!=null){
				scope = Scopes.scopeFor(res.allContents.toList.filter[d| d instanceof EClass])
			}
		
		return scope
	}
	
	def IScope scope_ReferencedModelElement_type(ReferencedModelElement refType,EReference ref){
 		var scope = IScope.NULLSCOPE
			if(refType.local){
				var me = refType.eContainer as ModelElement
				var graphModel = me.graphModel
				var types = new ArrayList<Type>()
				types += graphModel.types.unmodifiableView + graphModel.nodes.unmodifiableView + graphModel.edges.unmodifiableView
				types += graphModel
				
				scope = Scopes.scopeFor(types)
			}else{
				var res = null as Resource
				try{
					res = CincoUtil::getResource(refType.imprt.importURI, refType.eResource)
				}catch(Exception e){
					return scope
				}
				
				if(res!=null){
					scope = Scopes.scopeFor(res.allContents.toList.filter[d| d instanceof ModelElement])
				}
			}
		return scope
	}
	
	def dispatch GraphModel getGraphModel(ModelElement element){
		switch(element){
			GraphModel: return element
			default: return element.eContainer as GraphModel
		}
	}
	
	def dispatch getGraphModel(ContainingElement ce){
		switch(ce){
			GraphModel: return ce
			default: return ce.eContainer as GraphModel
		}
	}
	
	def IScope scope_ReferencedType_type(ReferencedType refType,EReference ref){
		if(refType instanceof ReferencedModelElement && ref==MglPackage.eINSTANCE.referencedModelElement_Type){
			return scope_ReferencedModelElement_type(refType as ReferencedModelElement,ref)
			}else if(refType instanceof ReferencedEClass && ref == MglPackage.eINSTANCE.referencedEClass_Type){
			return scope_ReferencedEClass_type(refType as ReferencedEClass,ref)
		}else{
			return super.getScope(refType,ref)
		}
	}
	
	def IScope scope_ComplexAttribute_type(ComplexAttribute it, EReference ref){
		val gm = it.modelElement.graphModel
		Scopes.scopeFor(gm.nodes+gm.types+gm.edges+#[gm])
	}
	
	def IScope scope_OutgoingEdgeElementConnection_connectingEdges(OutgoingEdgeElementConnection oeec, EReference ref){
		Scopes.scopeFor(oeec.connectedElement.graphModel.edges)
	}
	
	
	def IScope scope_IncomingEdgeElementConnection_connectingEdges(IncomingEdgeElementConnection ieec, EReference ref){
		Scopes.scopeFor(ieec.connectedElement.graphModel.edges)
	}
	
	def loadResource(String uri){
		try{
			var url = new URL(uri);
			return url.openConnection.inputStream
		
		}catch(Exception e){
			throw new RuntimeException(e);
		}
	}
	
	def URI getURI(IFile file) {
        if (file.exists) 
        	URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true)
        else null
	}
	
}
