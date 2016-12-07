/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.productdefinition.ui.contentassist

import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.utils.xtext.PickColorApplier
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import productDefinition.Annotation

/**
 * see http://www.eclipse.org/Xtext/documentation.html#contentAssist on how to customize content assistant
 */
class CPDProposalProvider extends AbstractCPDProposalProvider {
	
	override complete_Color(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var proposal = createCompletionProposal("Pick color...", context);
		if (proposal instanceof ConfigurableCompletionProposal) {
			var configProp = proposal as ConfigurableCompletionProposal
			configProp.setTextApplier(new PickColorApplier("("))
		}
		
		acceptor.accept(proposal)
		super.complete_Color(model, ruleCall, context, acceptor)
	}
	
	override completeColor_R(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var proposal = createCompletionProposal("Pick color...", context);
		if (proposal instanceof ConfigurableCompletionProposal) {
			var configProp = proposal as ConfigurableCompletionProposal
			configProp.setTextApplier(new PickColorApplier(""))
		}
		
		acceptor.accept(proposal)
		
		super.completeColor_R(model, assignment, context, acceptor)
		
	}
	
	override completeAnnotation_Value(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (model instanceof Annotation) {
			var annot = model as Annotation
			var pluginReg = PluginRegistry::getInstance();
			var metaPlugins = pluginReg.getSuitableCPDMetaPlugins(annot.name);
			
			if(!metaPlugins.nullOrEmpty){
			
				for(mp: metaPlugins){
					var myAcceptor = mp.acceptor
					if(myAcceptor!=null){
						for(acc: myAcceptor.getAcceptedStrings(annot)){
							
							var proposal = createCompletionProposal(acc, context);
							if (proposal instanceof ConfigurableCompletionProposal) {
								var configProp = proposal as ConfigurableCompletionProposal
								configProp.setTextApplier(myAcceptor.getTextApplier(annot))
							}			
							acceptor.accept(proposal)
						}
					}
				}
			}
		}
	}
	
	override completeCincoProduct_Features(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		for(bgp:Platform.bundleGroupProviders){
		  			for(feature: bgp.bundleGroups){
		  				acceptor.accept(createCompletionProposal(feature.identifier,context))	
		  			}
		  		
		}
		var workspace = ResourcesPlugin.getWorkspace();
		for (project: workspace.root.projects){
			if(project.description.hasNature("org.eclipse.pde.FeatureNature"))
				acceptor.accept(createCompletionProposal(project.description.name,context))
		}
		
		
	}
	
	override completeCincoProduct_Plugins(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		  var pluginModels = org.eclipse.pde.core.plugin.PluginRegistry.allModels
		  
		  for(pluginModel: pluginModels){
		  		
		  	val bundleDesription = pluginModel.bundleDescription
		  	if(bundleDesription!=null){
		  		acceptor.accept(createCompletionProposal(bundleDesription.symbolicName,context))
		  	}
		  		
		  }
	}
}
