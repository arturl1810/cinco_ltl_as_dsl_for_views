package de.jabc.cinco.meta.plugin.primeviewer.tmpl.file

import de.jabc.cinco.meta.core.utils.MGLUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.ModelElement
import mgl.Node
import mgl.ReferencedType
import org.eclipse.emf.ecore.EClass

class ProviderHelperTmpl extends FileTemplate {
	
	static extension GeneratorUtils = new GeneratorUtils
	
	ReferencedType referencedType
	CharSequence primeTypeName
	CharSequence primeTypeNameLower
	
	
	new(Node primeNode) {
		referencedType = MGLUtil.retrievePrimeReference(primeNode)
		primeTypeName = primeNode.primeTypeName
		primeTypeNameLower = primeTypeName.toString.toLowerCase
	}
	
	override getTargetFileName() {
		'''«primeTypeName»ProviderHelper.java'''
	}
	
	override template() {
		switch it:referencedType.type {
			EClass : referencedEClassTemplate
			ModelElement : referencedModelElementTemplate
		}
	}
	
	def referencedEClassTemplate(EClass eClass) '''
		package «package»;
				
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EObject;
		
		
		public class «eClass.name»ProviderHelper {
			
			static EClass «primeTypeNameLower»EClass() {
				return (EClass)org.eclipse.emf.ecore.EPackage.Registry.INSTANCE.getEPackage("«eClass.EPackage.nsURI»").getEClassifier("«primeTypeName»");
			}
			
			static boolean isA«primeTypeName»(EObject eObj) {
				return eObj.eClass().equals(«primeTypeNameLower»EClass()) || eObj.eClass().getEAllSuperTypes().contains(«primeTypeNameLower»EClass());
					
			}
				
			
		}
	'''
	
	
	def referencedModelElementTemplate(ModelElement referenced) '''
		package «package»;
				
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EObject;
		
		import «referenced.graphModel.fqEPackageName»;
		
		public class «primeTypeName»ProviderHelper {
			
			static EClass «primeTypeNameLower»EClass() {
				return «referenced.graphModel.ePackageName».eINSTANCE.get«primeTypeName»();
			}
			
			static boolean isA«primeTypeName»(EObject eObj) {
				return eObj.eClass().equals(«primeTypeNameLower»EClass()) || eObj.eClass().getEAllSuperTypes().contains(«primeTypeNameLower»EClass());
					
			}
				
			
		}
	'''
	
}