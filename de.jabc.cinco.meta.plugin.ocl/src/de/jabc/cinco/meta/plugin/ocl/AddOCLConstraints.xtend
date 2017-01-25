package de.jabc.cinco.meta.plugin.ocl

import mgl.Annotation
import mgl.GraphModel
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory

class AddOCLConstraints {
	
	static val SETTING_DEL = "settingDelegates"
	static val INVOCATION_DEL = "invocationDelegates"
	static val VALIDATION_DEL = "validationDelegates"
	
	val ecoreSource = "http://www.eclipse.org/emf/2002/Ecore";
	val oclSource = "http://www.eclipse.org/emf/2002/Ecore/OCL";
	var GraphModel gm
	val EPackage ePack
	
	new (GraphModel graphModel, EPackage pack) {
		this.gm = graphModel
		this.ePack = pack
	}
	
	def addOCLConstraints() {
		val initAnnot = createEcoreAnnotation(ecoreSource)
		initAnnot.details.put(SETTING_DEL, oclSource)
		initAnnot.details.put(INVOCATION_DEL, oclSource)
		initAnnot.details.put(VALIDATION_DEL, oclSource)
		
		ePack.EAnnotations.add(initAnnot)
		
		ePack.eResource.save(null)
		
		val annots = gm.annotations.filter[name.equals("oclExpression")]
		gm.eClass.createAnnotation(annots)
		
	}
	
	def createAnnotation(EClass clazz, Iterable<Annotation> it) {
		val ecoreAnnotation = EcoreFactory.eINSTANCE.createEAnnotation
		ecoreAnnotation.source = ecoreSource
	}
	
	def createEcoreAnnotation(String source) {
		val annot = EcoreFactory.eINSTANCE.createEAnnotation
		annot.source = source
		return annot
	}
	
	
}