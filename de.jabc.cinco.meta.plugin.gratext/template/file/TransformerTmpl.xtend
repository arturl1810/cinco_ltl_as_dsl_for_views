package file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class TransformerTmpl extends FileTemplate {
	
//	String projectBasePackage
//	
//	new(String projectBasePackage) {
//		this.projectBasePackage = projectBasePackage
//	}
	
	override getTargetFileName() '''«model.name»GratextTransformer.xtend'''
	
	override template() '''	
		package «package»
		
		import graphmodel.internal.InternalModelElementContainer
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.Transformer
		import «model.beanPackage».«model.name.toLowerCase.toFirstUpper»Package
		import «basePackage»._Placed
		import org.eclipse.emf.ecore.EPackage
		
		class «model.name»GratextTransformer extends Transformer {
		
			new() { super(
				EPackage.Registry.INSTANCE.getEFactory("«model.nsURI»"),
				EPackage.Registry.INSTANCE.getEPackage("«model.nsURI»/internal"),
				«model.name.toLowerCase.toFirstUpper»Package.eINSTANCE.get«model.name»
			)}
		
			dispatch def getIndex(_Placed it) {
				if (index >= 0) index
				else (eContainer as InternalModelElementContainer).modelElements.indexOf(it)
			}
		}
	'''
	
}