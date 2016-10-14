package de.jabc.cinco.meta.core.pluginregistry.validation

import static de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl.*
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry

import mgl.Annotation
import mgl.Attribute
import mgl.Edge
import mgl.GraphModel
import mgl.MglPackage
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedType
import mgl.UserDefinedType

import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check


class MetaPluginValidator extends AbstractMetaPluginValidator {
	
	static MetaPluginValidator instance
	
	ArrayList<IMetaPluginValidator> validators = new ArrayList;
	
	static def getInstance() {
		if (instance == null)
			instance = new MetaPluginValidator();

		return instance;
	}

	def putValidator(IMetaPluginValidator validator) {
		validators += validator;
	}
	
	@Check
	def checkMetaPluginRegisteredForAnnotation(Annotation annotation) {
		if (!annotation.metaPluginExists) error(
			"Annotation: "+annotation.name+" is unknown. 
			Please Register a suitable MetaPlugin or remove annotation.",
            MglPackage.Literals::ANNOTATION__NAME
        )
	}
	
	@Check
	def checkValidators(EObject eObj) {
		for (v : validators) {
			var pair = v.checkAll(eObj);
			if (pair != null)
				error(pair.getMessage, pair.getFeature());
		}
	}
	
	private def metaPluginExists(Annotation annotation) {
		val typeId = annotation.typeId
		typeId != null
			&& ! PluginRegistry::instance.getSuitableMetaPlugins(annotation.name, typeId).nullOrEmpty
			|| ! PluginRegistry::instance.getSuitableMetaPlugins(annotation.name).nullOrEmpty
	}
	
	private def getTypeId(Annotation annotation) {
		switch annotation.parent {
			NodeContainer : NODE_CONTAINER_ANNOTATION
			Node: NODE_ANNOTATION
			Edge: EDGE_ANNOTATION
			GraphModel: GRAPH_MODEL_ANNOTATION
			UserDefinedType: TYPE_ANNOTATION
			ReferencedType: PRIME_ANNOTATION
			Attribute: ATTRIBUTE_ANNOTATION
			default: null
		}
	}
}