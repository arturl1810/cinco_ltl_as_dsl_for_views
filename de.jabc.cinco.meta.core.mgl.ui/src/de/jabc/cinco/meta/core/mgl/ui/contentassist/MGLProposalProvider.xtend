/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.ui.contentassist

import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistryEntry
import de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl
import java.util.Set
import mgl.Annotation
import mgl.Edge
import mgl.GraphModel
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedType
import mgl.Type
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import mgl.UserDefinedType
import mgl.Attribute
import org.eclipse.xtext.nodemodel.impl.LeafNode
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import de.jabc.cinco.meta.core.utils.xtext.ChooseFileTextApplier
import mgl.Annotatable

/**
 * see http://www.eclipse.org/Xtext/documentation/latest/xtext.html#contentAssist on how to customize content assistant
 */
class MGLProposalProvider extends AbstractMGLProposalProvider {
	
	val registry = PluginRegistry::instance
	
//	override completeGraphModel_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
//		val annots = registry.getAnnotations(PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION)
//		annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//	}
	
//	override completeNode_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
//		if (model instanceof Node) {
//			val node = model as Node
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::NODE_ANNOTATION)
//			val nodeAnnots = node.annotations
//			nodeAnnots.forEach[ a | if (annots.contains(a.name)) annots.remove(a.name)]
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		} else {
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::NODE_ANNOTATION)
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		}
//	}
	
	override completeAnnotation_Name(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		var parent  = null as Annotatable 
		if(model instanceof Annotation)
			parent = (model as Annotation).parent
		if(parent!=null){
			if(parent instanceof GraphModel)
				(registry.getAnnotations(PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
			if(parent instanceof Node)
				(registry.getAnnotations(PluginRegistryEntryImpl::NODE_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
			if(parent instanceof Edge)
				(registry.getAnnotations(PluginRegistryEntryImpl::EDGE_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
			if(parent instanceof ReferencedType)
				(registry.getAnnotations(PluginRegistryEntryImpl::PRIME_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
			if(parent instanceof Attribute)
				(registry.getAnnotations(PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
			if(parent instanceof NodeContainer)
				(registry.getAnnotations(PluginRegistryEntryImpl::NODE_CONTAINER_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]	
			if(parent instanceof UserDefinedType)
				(registry.getAnnotations(PluginRegistryEntryImpl::TYPE_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
		}else{
			(registry.getAnnotations(PluginRegistryEntryImpl::GENERAL_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal(a,context))]
		}
	}
	override completeGraphModel_IconPath(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		var proposal = createCompletionProposal("Choose File...", context);
		if (proposal instanceof ConfigurableCompletionProposal) {
			var configProp = proposal as ConfigurableCompletionProposal
			configProp.setTextApplier(new ChooseFileTextApplier(model))
		}
		acceptor.accept(proposal)
		
		
	}
//	override completeEdge_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
//		if(model instanceof Edge){
//			val edge = model as Edge
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::EDGE_ANNOTATION)
//			val edgeAnnots = edge.annotations
//			edgeAnnots.forEach[ a | if (annots.contains(a.name)) annots.remove(a.name)]
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		} else {
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::EDGE_ANNOTATION)
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		}
//	}
//	
//	override completeReferencedType_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
//		if(model instanceof ReferencedType){
//			val type = model as ReferencedType
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::PRIME_ANNOTATION)
//			val typeAnnots = type.annotations
//			typeAnnots.forEach[ a | if (annots.contains(a.name)) annots.remove(a.name)]
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		} else {
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::PRIME_ANNOTATION)
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		}
//	}
//		override completeUserDefinedType_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
//		if(model instanceof UserDefinedType){
//			val type = model as ReferencedType
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::TYPE_ANNOTATION)
//			val typeAnnots = type.annotations
//			typeAnnots.forEach[ a | if (annots.contains(a.name)) annots.remove(a.name)]
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		} else {
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::TYPE_ANNOTATION)
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		}
//	}
//	override completeAttribute_Annotations(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
//		if(model instanceof Attribute){
//			val type = model as Attribute
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION)
//			val typeAnnots = type.annotations
//			typeAnnots.forEach[ a | if (annots.contains(a.name)) annots.remove(a.name)]
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		} else {
//			val annots = registry.getAnnotations(PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION)
//			annots.forEach[a | acceptor.accept(createCompletionProposal(a, context))]
//		}
//	}

	override completeNodeContainer_ContainableElements(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		
		
	}
	
	override completeGraphModel_ContainableElements(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		
		
	}
	
	override completeGraphicalElementContainment_Type(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if(model instanceof GraphModel){
			
			val graphModel =model as GraphModel 
			for(node:graphModel.nodes){
				acceptor.accept(createCompletionProposal(node.name,context))
			}
			for(container:graphModel.nodeContainers){
				acceptor.accept(createCompletionProposal(container.name,context))
			}
		}else if(model instanceof NodeContainer){
			var parentModel = model.eContainer() as GraphModel
			for(node:parentModel.nodes){
				acceptor.accept(createCompletionProposal(node.name,context))
			}
			for(container:parentModel.nodeContainers){
				acceptor.accept(createCompletionProposal(container.name,context))
			}
		}
	}
	
	override completeAnnotation_Value(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var annot = null as Annotation
		var parentModel = null as EObject
		var metaPlugins = null as Set<PluginRegistryEntry>
		if (model instanceof Annotation) {
			annot = model as Annotation
			parentModel = annot.parent
			metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::GENERAL_ANNOTATION)
			if(metaPlugins==null){
			if(parentModel instanceof Node)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::NODE_ANNOTATION)
				
			if(parentModel instanceof UserDefinedType)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::TYPE_ANNOTATION)
				
			if(parentModel instanceof ReferencedType)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::PRIME_ANNOTATION)
				
			if(parentModel instanceof Attribute)
					metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION)
				
			if(parentModel instanceof Edge)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::EDGE_ANNOTATION)
				
			if(parentModel instanceof GraphModel)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION)
			if(parentModel instanceof NodeContainer)
				metaPlugins = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::NODE_CONTAINER_ANNOTATION)
			
			}else{
				if(parentModel instanceof Node){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::NODE_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof UserDefinedType){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::TYPE_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof ReferencedType){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::PRIME_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof Attribute){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof Edge){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::EDGE_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof GraphModel){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}
			if(parentModel instanceof NodeContainer){
					var mp = registry.getSuitableMetaPlugins(annot.name,PluginRegistryEntryImpl::NODE_CONTAINER_ANNOTATION)
					if(mp!=null)
						metaPlugins += mp
				}		
			}	
			if(metaPlugins!=null){
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
	
}


