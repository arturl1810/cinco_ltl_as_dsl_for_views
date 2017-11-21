/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.ui.contentassist

import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistryEntry
import de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl
import de.jabc.cinco.meta.core.utils.xtext.ChooseFileTextApplier
import java.util.ArrayList
import java.util.Set
import mgl.Annotation
import mgl.Attribute
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.ReferencedType
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.emf.common.util.URI
import mgl.ModelElement
import mgl.Type
import mgl.ReferencedEClass
import org.eclipse.emf.ecore.EClass
import de.jabc.cinco.meta.core.utils.xtext.ChooseWizard
import java.util.LinkedList
import mgl.GraphicalModelElement
import mgl.MglPackage
import mgl.ComplexAttribute

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
		
		
	}
	
	
	override complete_Annotation(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
			val semanticElement = context.currentNode.semanticElement
			if(semanticElement!=model && !(semanticElement instanceof Annotation)){
				
				(registry.getAnnotations(PluginRegistryEntryImpl::GENERAL_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				if(semanticElement instanceof GraphModel){
					(registry.getAnnotations(PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION)).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof NodeContainer){
					registry.getAnnotations(PluginRegistryEntryImpl::NODE_CONTAINER_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof Node){
					registry.getAnnotations(PluginRegistryEntryImpl::NODE_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof Edge){
					registry.getAnnotations(PluginRegistryEntryImpl::EDGE_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof Attribute){
					registry.getAnnotations(PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof ReferencedType){
					registry.getAnnotations(PluginRegistryEntryImpl::PRIME_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}else if(semanticElement instanceof UserDefinedType){
					registry.getAnnotations(PluginRegistryEntryImpl::TYPE_ANNOTATION).forEach[a|acceptor.accept(createCompletionProposal("@"+a,context))]
				}
			
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
	
	override completeGraphicalElementContainment_Types(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if(model instanceof GraphModel){
			
			val graphModel =model as GraphModel 
			for(node:graphModel.nodes){
				acceptor.accept(createCompletionProposal(node.name,context))
			}
			for(container:graphModel.nodes.filter(NodeContainer)){
				acceptor.accept(createCompletionProposal(container.name,context))
			}
		}else if(model instanceof NodeContainer){
			var parentModel = model.eContainer() as GraphModel
			for(node:parentModel.nodes){
				acceptor.accept(createCompletionProposal(node.name,context))
			}
			for(container:parentModel.nodes.filter(NodeContainer)){
				acceptor.accept(createCompletionProposal(container.name,context))
			}
		}
	}
	
	override completeIncomingEdgeElementConnection_ConnectingEdges(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if(model instanceof GraphModel){
			model.edges.forEach[acceptor.accept(createCompletionProposal(name,context))]
		}else if(model instanceof GraphicalModelElement){
			 (model.eContainer as GraphModel).edges.forEach[acceptor.accept(createCompletionProposal(name,context))]
		}
	}
	override completeOutgoingEdgeElementConnection_ConnectingEdges(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if(model instanceof GraphModel){
			model.edges.forEach[acceptor.accept(createCompletionProposal(name,context))]
		}else if(model instanceof GraphicalModelElement){
			 (model.eContainer as GraphModel).edges.forEach[acceptor.accept(createCompletionProposal(name,context))]
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
			if(checkAnnotations(annot.name)){
				var proposal = createCompletionProposal("New Class...", context);
				acceptor.accept(proposal)
				if (proposal instanceof ConfigurableCompletionProposal) {
				var configProp = proposal as ConfigurableCompletionProposal
				configProp.setTextApplier(new ChooseWizard(annot))
					}
				}
			}
		}
	
	
	
	def createAnnotations(){
		var annotationsForClasses = new LinkedList <String>
		annotationsForClasses.add("contextMenuAction")
		annotationsForClasses.add("doubleClickAction")
		annotationsForClasses.add("preDelete")
		annotationsForClasses.add("postCreate")
		annotationsForClasses.add("postAttributeValueChange")
		annotationsForClasses.add("postDelete")
		annotationsForClasses.add("postMove")
		annotationsForClasses.add("postResize")
		annotationsForClasses.add("postSelect")
		
		return annotationsForClasses
	}
	
	def checkAnnotations(String annotionname){
		var annotations = createAnnotations()
		for (var i = 0; i < annotations.size; i++){
			if(annotionname.equals(annotations.get(i))){
				return true
			}
		}
		return false
	}
	
	override completeReferencedModelElement_Type(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val refType = model as ReferencedModelElement
		if(refType.local){
			var pNode = refType.eContainer as Node
			val graphModel = pNode.graphModel
			var types = new ArrayList<Type>()
			types += graphModel.types.unmodifiableView + graphModel.nodes.unmodifiableView + graphModel.edges.unmodifiableView
			types += graphModel
			for(obj: types){
				acceptor.accept(createCompletionProposal(obj.name,context))
			}	
		}else{
			val rSet = refType.eResource.resourceSet
			val file = getFile(refType.imprt.importURI, refType.eResource)
			val res = rSet.getResource(getURI(file), true)
			if(res!=null){
				for(m: res.allContents.toList.filter[d| d instanceof ModelElement]){
					acceptor.accept(createCompletionProposal((m as ModelElement).name,context))
				}
			}
		}
		//super.completeReferencedModelElement_Type(model,assignment,context,acceptor);
	}
	
	override completeReferencedEClass_Type(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		
		if(model instanceof ReferencedEClass){
			val refType = model as ReferencedEClass
			val rSet = model.eResource.resourceSet
			val file = getFile(refType.imprt.importURI, refType.eResource)
			val res = rSet.getResource(getURI(file), true)
			res?.allContents.filter(EClass).forEach[acceptor.accept(createCompletionProposal((it as EClass).name,context))]
				
		}
		
	}
	
	def URI getURI(IFile file) {
        if (file!=null && file.exists) 
        	URI.createPlatformResourceURI(file.getFullPath().toPortableString(), true)
        else null
	}
	
	def IFile getFile(String path, Resource res) {
        if (path == null || path.isEmpty)
        	return null
        val root = ResourcesPlugin.workspace.root
        val resFile = if (res.URI.isPlatform)
        	root.getFile(new Path(res.getURI().toPlatformString(true)))
        else root.getFileForLocation(Path.fromOSString(res.getURI().path()))
        val uri = URI.createURI(path)
        if (uri.isPlatform)
        	root.getFile(new Path(uri.toPlatformString(true)))
        else resFile.getProject().getFile(path)
	}
	
	
	// Attributes
	
	override completeComplexAttribute_Type(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		
		//(model as ComplexAttribute).modelElement
		(model as ModelElement).graphModel.attributeTypeNames.forEach[acceptor.accept(createCompletionProposal(it,context))]
		
	}
	
	
	override completeReferencedEClass_Imprt(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		super.completeReferencedEClass_Imprt(model,assignment,context,acceptor)
	}
	
	
	def attributeTypeNames(GraphModel it){
		(edges+nodes+types).map[name]+MglPackage.eINSTANCE.EDataTypeType.ELiterals.map[name]+#[name]
	}
	
	def GraphModel getGraphModel(ModelElement element){
		switch(element){
			GraphModel: return element
			default: return element.eContainer as GraphModel
		}
	}
	
}


