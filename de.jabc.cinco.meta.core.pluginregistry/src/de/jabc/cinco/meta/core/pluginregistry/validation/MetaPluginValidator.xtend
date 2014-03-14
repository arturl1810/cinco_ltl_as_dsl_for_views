package de.jabc.cinco.meta.core.pluginregistry.validation

import mgl.Edge
import mgl.MglPackage
import mgl.Node
import org.eclipse.xtext.validation.Check
import mgl.GraphModel
import mgl.NodeContainer
import mgl.ReferencedType
import mgl.Annotation
import de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import mgl.Attribute
import mgl.UserDefinedType

class MetaPluginValidator extends AbstractMetaPluginValidator {
	
	static MetaPluginValidator instance
	
	ArrayList<IMetaPluginValidator> validators = new ArrayList;
	
	static def getInstance(){
		if(instance==null)
			instance = new MetaPluginValidator();
		
		return instance;	
	}
	def putValidator(IMetaPluginValidator validator){
		validators += validator;
	}
	 @Check
	def checkMetaPluginRegisteredForAnnotation(Annotation annotation){
		if(annotation.parent instanceof Node){
			//val tmp = 
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::NODE_ANNOTATION).nullOrEmpty)
				return
			
			
		}else if(annotation.parent instanceof Edge){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::EDGE_ANNOTATION).nullOrEmpty)
				return
		
		}else if (annotation.parent instanceof GraphModel){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::GRAPH_MODEL_ANNOTATION).nullOrEmpty)
				return
		}else if(annotation.parent instanceof NodeContainer){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::NODE_CONTAINER_ANNOTATION).nullOrEmpty)
				return
		}else if(annotation.parent instanceof UserDefinedType){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::TYPE_ANNOTATION).nullOrEmpty)
				return
		}else if(annotation.parent instanceof ReferencedType){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::PRIME_ANNOTATION).nullOrEmpty)
				return
			
		}if(annotation.parent instanceof Attribute){
			if(!PluginRegistry::instance.getSuitableMetaPlugins(annotation.name,PluginRegistryEntryImpl::ATTRIBUTE_ANNOTATION).nullOrEmpty)
				return
				
		}
		if(PluginRegistry::instance.getSuitableMetaPlugins(annotation.name)==null||PluginRegistry::instance.getSuitableMetaPlugins(annotation.name).empty)
			error("Annotation: "+annotation.name+" is unknown. Please Register a suitable MetaPlugin or remove annotation.",MglPackage$Literals::ANNOTATION__NAME)
	}
	@Check
	def checkValidators(EObject eObj){
		for(v: validators){
			var pair = v.checkAll(eObj);
			if(pair!=null)
				error(pair.getMessage,pair.getFeature());
		}
	}
	
}