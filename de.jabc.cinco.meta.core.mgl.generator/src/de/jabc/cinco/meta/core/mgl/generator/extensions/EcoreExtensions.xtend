package de.jabc.cinco.meta.core.mgl.generator.extensions

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

class EcoreExtensions {
	static extension EcoreFactory = EcoreFactory.eINSTANCE
	static extension EcorePackage = EcorePackage.eINSTANCE
	val static annotationSource = "http://www.eclipse.org/emf/2002/GenModel"
	val static key= "body"
	
	def static  EReference createReference(EClass eClass, String name, EClass type, int lowerBound, int upperBound, boolean containment, EReference opposite){
		var eReference = createEReference
		eReference.name = name
		eReference.EType = type
		eReference.lowerBound = lowerBound
		eReference.upperBound = upperBound
		eReference.containment = containment
		if(opposite !== null){
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
		eOp.setEOperationBody(content)
		
		eClass.EOperations.add(eOp)
		eOp
	}

	def static createGenericListEOperation(EClass eClass, String name, EClassifier type,String content, EParameter ...parameters){
		val eOp = createEOperation
		val eGen = createEGenericType
		
		eGen.EClassifier = EcorePackage.eINSTANCE.getEClassifier("EEList")
		eOp.EGenericType = eGen				 
		val eGen2 = createEGenericType
		eGen.ETypeArguments += eGen2
		val eGen3 = createEGenericType
		eGen2.EUpperBound = eGen3
		eGen3.EClassifier = type
		eOp.lowerBound = 1
		eOp.upperBound = 1
		eOp.EParameters += parameters
		eOp.name = name
		eOp.setEOperationBody(content)
		
		eClass.EOperations.add(eOp)
		eGen3
	}
	
	protected def static boolean setEOperationBody(EOperation eOp,String content) {
		val eAnnotation = createEAnnotation
		eAnnotation.source = annotationSource
		eAnnotation.details.put(key,content)
		eOp.EAnnotations += eAnnotation
	}
	
	def static createGenericListEOperation(EClass eClass, String name, EClassifier type, int lowerBound, int upperBound, CharSequence content, EParameter ...parameters){
		createGenericListEOperation(eClass,name,type,content.toString,parameters)
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
	
	def static createEStringParameter(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EString,name,lb,ub)
	}
	
	def static createEIntParameter(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EInt,name,lb,ub)
	}
	
	def static createEBooleanParameter(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EBoolean,name,lb,ub)
	}
	
	def static createEObjectParameter(String name, int lb, int ub) {
		createEParameter(EcorePackage.eINSTANCE.EObject,name,lb,ub)
	}
	
}