package de.jabc.cinco.meta.core.pluginregistry.validation

import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import java.util.ArrayList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import productDefinition.Annotation
import productDefinition.ProductDefinitionPackage

class CPDMetaPluginValidator extends AbstractCPDMetaPluginValidator {
	
	static CPDMetaPluginValidator instance
	
	ArrayList<IMetaPluginValidator> validators = new ArrayList;
	
	static def getInstance() {
		if (instance == null)
			instance = new CPDMetaPluginValidator();

		return instance;
	}

	def putValidator(IMetaPluginValidator validator) {
		validators += validator;
	}
	
	@Check
	def checkMetaPluginRegisteredForAnnotation(Annotation annotation) {
		if (!annotation.metaPluginExists) error(
			"Annotation: "+annotation.name+" is unknown. 
			Please Register a suitable CPD MetaPlugin or remove annotation.",
            ProductDefinitionPackage.Literals::ANNOTATION__NAME
        )
	}
	
	@Check
	def checkValidators(EObject eObj) {
		PluginRegistry::instance.pluginCPDGenerators
			.map[validator].map[checkAll(eObj)].forEach[applyResult]
	}
	
	private def boolean metaPluginExists(Annotation annotation) {
		return !PluginRegistry::instance.getSuitableCPDMetaPlugins(annotation.name).nullOrEmpty
	}

}