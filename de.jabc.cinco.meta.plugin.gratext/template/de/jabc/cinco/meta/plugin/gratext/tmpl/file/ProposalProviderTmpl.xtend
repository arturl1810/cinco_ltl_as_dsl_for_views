package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class ProposalProviderTmpl extends FileTemplate {
	
	override getTargetFileName() '''«model.name»GratextProposalProvider.xtend'''
	
	override template() '''
		package «package»
		
		import org.eclipse.emf.ecore.EObject
		
		class «model.name»GratextProposalProvider extends Abstract«model.name»GratextProposalProvider {
			
			override getDisplayString(EObject element, String qualifiedNameAsString, String shortName) {
				element.eClass.name + " " + (
					labelProvider.getText(element) ?: super.getDisplayString(element, qualifiedNameAsString, shortName)
				)
			}
			
		}
	'''
}