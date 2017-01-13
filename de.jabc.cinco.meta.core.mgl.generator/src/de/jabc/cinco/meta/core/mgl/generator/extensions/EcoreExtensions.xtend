package de.jabc.cinco.meta.core.mgl.generator.extensions

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EClassifier

class EcoreExtensions {
	
	val static annotationSource = "http://www.eclipse.org/emf/2002/GenModel"
	val static key= "body"
	
	def static  EReference createReference(EClass eClass, String name, EClass type, int lowerBound, int upperBound, boolean containment, EReference opposite){
		var eReference = EcoreFactory.eINSTANCE.createEReference
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
		val eAttr = EcoreFactory.eINSTANCE.createEAttribute
		eAttr.name = name 
		eAttr.EType = type
		eAttr.upperBound = upperBound 
		eAttr.lowerBound = lowerBound
		eClass.EStructuralFeatures.add(eAttr)
		eAttr
	}
	
	
	
	def static createEOperation(EClass eClass, String name, EClassifier type, int lowerBound, int upperBound, String content, EParameter ...parameters){
		val eOp = EcoreFactory.eINSTANCE.createEOperation
		eOp.EType = type
		eOp.lowerBound = lowerBound
		eOp.upperBound = upperBound
		eOp.EParameters += parameters
		eOp.name = name
		val eAnnotation = EcoreFactory.eINSTANCE.createEAnnotation
		eAnnotation.source = annotationSource
		eAnnotation.details.put(key,content)
		eOp.EAnnotations += eAnnotation
		
		eClass.EOperations.add(eOp)
		eOp
	}
	
	
}