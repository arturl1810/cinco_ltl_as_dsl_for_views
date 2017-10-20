package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor

class TransformerTemplate extends AbstractGratextTemplate {
	
	def nameFirstUpper(GraphModelDescriptor model) {
		model.name.toLowerCase.toFirstUpper
	}
	
	override template() '''	
		package «project.basePackage».generator
		
		import graphmodel.internal.InternalModelElementContainer
		import de.jabc.cinco.meta.plugin.gratext.runtime.resource.Transformer
		import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package
		import «project.basePackage»._Placed
		import org.eclipse.emf.ecore.EPackage
		
		class «model.name»GratextTransformer extends Transformer {
		
			new() { super(
				EPackage.Registry.INSTANCE.getEFactory("«graphmodel.nsURI»"),
				EPackage.Registry.INSTANCE.getEPackage("«graphmodel.nsURI»/internal"),
				«model.nameFirstUpper»Package.eINSTANCE.get«model.name»
			)}
		
			dispatch def getIndex(_Placed it) {
				if (index >= 0) index
				else (eContainer as InternalModelElementContainer).modelElements.indexOf(it)
			}
		}
	'''
}