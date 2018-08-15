package de.jabc.cinco.meta.core.mgl.generator.extensions

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.ETypeParameter



class EcoreExtensions {
	static extension EcoreFactory = EcoreFactory.eINSTANCE
	val static annotationSource = "http://www.eclipse.org/emf/2002/GenModel"
	val static key= "body"
	
	def static  EReference createReference(EClass eClass, String name, EClass type, int lowerBound, int upperBound, boolean containment, EReference opposite){
		var eReference = createEReference
		eReference.name = name
		eReference.EType = type
		eReference.lowerBound = lowerBound
		eReference.upperBound = upperBound
		eReference.containment = containment
		if(opposite!=null){
			eReference.EOpposite = opposite	
			opposite.EOpposite = eReference
		}
		eClass.EStructuralFeatures.add(eReference)
		eReference
	}
	
	def static EAttribute createEAttribute(EClass eClass, String name, EClassifier type, Integer lowerBound, Integer upperBound){
		val eAttr = createEAttribute
		eAttr.name = name 
		eAttr.EType = type
		eAttr.upperBound = upperBound 
		eAttr.lowerBound = lowerBound
		eClass.EStructuralFeatures.add(eAttr)
		eAttr
	}
	
	
	
	def static createEOperation(EClass eClass, String name, EClassifier type, int lowerBound, int upperBound, String content, EParameter ...parameters){
		val eOp = createEOperation
		eOp.EType = type
		eOp.lowerBound = lowerBound
		eOp.upperBound = upperBound
		eOp.EParameters += parameters
		eOp.name = name
		val eAnnotation = createEAnnotation
		eAnnotation.source = annotationSource
		eAnnotation.details.put(key,content)
		eOp.EAnnotations += eAnnotation
		
		eClass.EOperations.add(eOp)
		eOp
	}
	
	
	def static createEOperation(EClass eClass, String name, EClassifier type, int lowerBound, int upperBound, CharSequence content, EParameter ...parameters){
		createEOperation(eClass,name,type,lowerBound,upperBound,content.toString,parameters)
	}
	
	
	
	def static createEParameter(EClass type, String name, int lowerBound, int upperBound) {
		val eParam = createEParameter;
		eParam.EType = type
		eParam.name = name
		eParam.lowerBound = lowerBound
		eParam.upperBound = upperBound
		eParam
	}

	def static createEParameter(EDataType type, String name, int lowerBound, int upperBound) {
		val eParam = createEParameter;
		eParam.EType = type
		eParam.name = name
		eParam.lowerBound = lowerBound
		eParam.upperBound = upperBound
		eParam
	}
	
	def static createEString(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EString,name,lb,ub)
	}
	
	def static createEInt(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EInt,name,lb,ub)
	}
	
	def static createEBoolean(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EBoolean,name,lb,ub)
	}
	
	def static createEObject(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EObject,name,lb,ub)
	}
	
}