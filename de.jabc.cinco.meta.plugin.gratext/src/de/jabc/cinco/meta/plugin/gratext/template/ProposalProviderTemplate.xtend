package de.jabc.cinco.meta.plugin.gratext.template

class ProposalProviderTemplate extends AbstractGratextTemplate {

	override template() '''
		package «project.basePackage».contentassist
		
		import org.eclipse.emf.ecore.EObject
		
		class «project.targetName»ProposalProvider extends Abstract«project.targetName»ProposalProvider {
			
			override getDisplayString(EObject element, String qualifiedNameAsString, String shortName) {
				element.eClass.name + " " + (
					labelProvider.getText(element) ?: super.getDisplayString(element, qualifiedNameAsString, shortName)
				)
			}
			
		}
	'''
}
