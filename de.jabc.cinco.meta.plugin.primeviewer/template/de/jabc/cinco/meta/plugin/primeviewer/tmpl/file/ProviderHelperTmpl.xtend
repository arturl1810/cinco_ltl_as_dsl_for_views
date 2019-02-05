package de.jabc.cinco.meta.plugin.primeviewer.tmpl.file
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Node
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import de.jabc.cinco.meta.core.utils.MGLUtil

class ProviderHelperTmpl extends FileTemplate{
	
	static extension GeneratorUtils = new GeneratorUtils
		
	Node node
	CharSequence primeTypeName
	CharSequence primeTypeNameLower
	CharSequence primeFqEPackageName
	CharSequence primeEPackageName
	
	
	new(Node primeNode) {
		node = primeNode
		primeTypeName = node.primeTypeName
		primeFqEPackageName = node.graphModel.fqEPackageName
		primeTypeNameLower = primeTypeName.toString.toLowerCase
		primeEPackageName = node.graphModel.ePackageName
	}
	
	override getTargetFileName() {
		'''«primeTypeName»ProviderHelper.java'''
	}
	
	override template(){
		val prime = MGLUtil.retrievePrimeReference(node)
		switch prime {
			ReferencedEClass : referencedEClassTemplate
			ReferencedModelElement : referencedModelElementTemplate
		}
	}
	
	def referencedEClassTemplate(){
	val primeEPackage = (MGLUtil.retrievePrimeReference(node) as ReferencedEClass).type.EPackage
	val nsuri = primeEPackage.nsURI
	return '''package «package»;
			
	import org.eclipse.emf.ecore.EClass;
	import org.eclipse.emf.ecore.EObject;
	
	
	public class «primeTypeName»ProviderHelper {
		
		static EClass «primeTypeNameLower»EClass() {
			return (EClass)org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.getEPackage("«nsuri»").getEClassifier("«primeTypeName»");
		}
		
		static boolean isA«primeTypeName»(EObject eObj) {
			return eObj.eClass().equals(«primeTypeNameLower»EClass()) || eObj.eClass().getEAllSuperTypes().contains(«primeTypeNameLower»EClass());
				
		}
			
		
	}
	
	
	'''
	}
	
	
	def referencedModelElementTemplate()'''
	package «package»;
			
	import org.eclipse.emf.ecore.EClass;
	import org.eclipse.emf.ecore.EObject;
	
	import «primeFqEPackageName»;
	
	public class «primeTypeName»ProviderHelper {
		
		static EClass «primeTypeNameLower»EClass() {
			return «primeEPackageName».eINSTANCE.get«primeTypeName»();
		}
		
		static boolean isA«primeTypeName»(EObject eObj) {
			return eObj.eClass().equals(«primeTypeNameLower»EClass()) || eObj.eClass().getEAllSuperTypes().contains(«primeTypeNameLower»EClass());
				
		}
			
		
	}
	
	
	'''
	
}